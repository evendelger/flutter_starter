# Старт реального проекта из шаблона

Порядок действий после копирования репозитория. Пункты 1–2 обязательны,
без них проект остаётся «шаблоном» и мешает работе.

## 1. Переименование

```sh
make rename NAME=my_app BUNDLE_ID=com.company.myapp APP_NAME="My App" DOMAIN=myapp.com
```

Скрипт переименует Dart-пакет и все импорты, описание в `pubspec.yaml`,
`Config.appName` и `Config.prefsNamespace`, ключ `appName` в ARB,
Android `namespace`/`applicationId`/`MainActivity` (вместе с каталогом),
iOS bundle id и отображаемые имена, схему и домен deep links. Затем сам
прогонит `flutter pub get`, `flutter gen-l10n` и `build_runner`.

Проверка: `make check` должен быть зелёным (нужен `bloc` CLI:
`dart pub global activate bloc_tools`).

## 2. CLAUDE.md

**Это самый важный шаг после переименования.** Файл написан для шаблона и
открывается двумя ограничениями — «не добавляй продуктовые фичи» и «экраны и
бизнес-логика принадлежат производным проектам». Если их не убрать, Claude
Code будет сопротивляться ровно той работе, ради которой заведён проект.

### Убрать или переписать

| Что | Где |
|---|---|
| Вводная рамка «This is a project template» и два ограничения под ней | начало файла |
| Команда `make rename` | раздел Commands |
| Раздел Rename tooling | ближе к концу Architecture |
| Оговорки «config ship with `example.com` placeholders», «assets ship empty», «Keep this feature dormant in the template», «in a derived project» | разделы API client, Theme & assets, Push notifications, Authentication |
| Конвенция `TODO(template):` | раздел Conventions |
| Абзац «CI & branches»: работа в шаблоне напрямую в `main`, доставка выключена — заменить моделью веток проекта (раздел 7 ниже) | раздел Commands |

### Оставить без изменений

- Весь раздел Architecture: слои и направление зависимостей, DI через scopes,
  роутинг Auto Route, BLoC и базовые классы, data-слой и обработка ошибок,
  Drift и типизированные SharedPreferences, API-клиент
- Commands и планка приёмки: `make check` + реальная сборка при изменении
  платформенного конфига или ассетов
- Ловушка `build.yaml` (файл вне glob'ов молча не генерируется) и список
  генерируемых файлов
- Разделы Conventions и Linting

### Дописать под проект

То, чего в шаблоне быть не может:

- назначение приложения в двух-трёх строках
- окружения и реальные API-адреса
- решение по авторизации: подключён ли `AuthGuard` или пользователь остаётся
  гостём
- включены ли push-уведомления
- доменные термины и сущности предметной области
- внешние сервисы и интеграции (аналитика, карты, платежи, крашлитика)

## 3. Конфигурация

- `config/development.json` и `config/production.json` — `API_BASE_URL`,
  `SITE_URL`, `SUPPORT_URL`, ссылки на сторы. Значения читаются только через
  `Config`, инлайнить их в коде нельзя
- `packages/client_api` — эндпоинты и DTO под своё API, после правок
  `build_runner` запускается **внутри этого пакета**

## 4. Ресурсы и оформление

- Иконка приложения и splash в `assets/`, затем `make splash`
  (каталоги `assets/images/` и `assets/splash/` в шаблоне пустые, в них лежит
  `.gitkeep` — удалять его нельзя, пустой объявленный каталог ассетов ломает
  сборку)
- Шрифт проекта: секция `fonts:` в `pubspec.yaml` + `fontFamily:
  FontFamily.<name>` в `AppTheme._buildTheme()`. По умолчанию системный
- Палитра в `AppPalette`, размеры и отступы в `UIConfig`

## 5. Push-уведомления (если нужны)

1. `flutterfire configure` — появятся `lib/firebase_options.dart`,
   `google-services.json` и `GoogleService-Info.plist`
2. Раскомментировать блок `Firebase.initializeApp()` +
   `NotificationService.setup()` в `MainRunner.run()`
3. В `notification_service.dart` заменить `Firebase.initializeApp()` на
   вариант с `DefaultFirebaseOptions`

Оба места помечены `TODO(template)`.

## 6. Авторизация (если обязательна)

По умолчанию вход необязателен: приложение стартует на главном экране,
неавторизованный пользователь — штатный гость, `UserScope.userOf` возвращает
`null`. Подставлять фейкового `User`, чтобы обойти проверку на null, нельзя.

Чтобы сделать вход обязательным:

1. Повесить `AuthGuard` на нужную ветку роутов — закомментированный пример в
   `AppRoutes.root`
2. Раскомментировать редирект в `AppListeners`
3. Реализовать вход в `AuthRepository` (помечено `TODO(template)`) и форму в
   `LoginScreen`

## 7. CI, ветки и релизы

CI рассчитан на GitHub Actions; для другого CI перенести те же шаги.

Без настройки работают проверки (`ci.yml`, job `check` = `make check` на
чистой кодогенерации), debug-сборка Android и iOS без подписи (только на
push в `main` и ручной запуск). Секреты для них не нужны.

Доставка в шаблоне выключена: подписанный dev-APK из `develop`, проверка
источника PR в `main` и `release.yml` (релиз по тегу) пропускаются, пока нет
переменной репозитория `DELIVERY_ENABLED`.

### Модель веток

```
feature/*, fix/*, chore/*, ci/*  ──PR──▶  develop  ──PR──▶  main  ──tag v1.2.3──▶  GitHub Release
```

- Разработка идёт в `develop`; push в `develop` собирает подписанный dev-APK
  (артефакт прогона, `applicationId` с суффиксом `.dev`)
- В `main` вливаются только `develop`, `release/*` и `hotfix/*` — это
  проверяет job `Release PR source`. После `hotfix/*` смёржить `main` обратно
  в `develop`
- Релизный PR `develop → main` мёржится **merge-коммитом**, не squash: иначе
  истории веток разойдутся и следующий релизный PR покажет уже влитые коммиты
  как новые
- Релиз — тег `v*` на коммите из `main` (тег вне `main` workflow отклоняет):
  `git switch main && git pull && git tag v1.0.0 && git push origin v1.0.0`.
  `--build-name` берётся из тега — держать `version` в `pubspec.yaml` в
  синхроне; release notes собираются из заголовков PR, поэтому заголовки в
  стиле conventional commits

### Включение

1. Ветка `develop` от `main`; **Settings → General → Default branch →
   `develop`** (туда же пойдут PR Dependabot)
2. `pubspec.lock` — в git: убрать строку из `.gitignore`, а из `make clean` —
   `rm pubspec.lock`. В шаблоне lock не хранится, у приложения релизные
   сборки должны быть воспроизводимы
3. Upload keystore (`make setup-android`) и четыре секрета
   (**Settings → Secrets and variables → Actions**):

   ```sh
   base64 < android/app/keystore.jks | gh secret set KEYSTORE_BASE64
   gh secret set STORE_PASSWORD
   gh secret set KEY_PASSWORD
   gh secret set KEY_ALIAS
   ```

   Keystore хранить вне репозитория (менеджер паролей): потеря upload-ключа —
   это процедура сброса через Play Console
4. `gh variable set DELIVERY_ENABLED --body true`
5. Защита веток (**Settings → Rules → Rulesets**) — после первого прогона CI,
   раньше имена проверок не появятся в списке:

   | | `develop` | `main` |
   |---|---|---|
   | Require a pull request | да | да |
   | Required status checks | `Format, analyze, test`, `Build Android (debug, development)` | то же + `Release PR source` |
   | Allowed merge methods | squash | merge commit |
   | Block force pushes, restrict deletions | да | да |

6. Когда в `config/*.json` появятся реальные значения — перенести их в
   секреты и записывать файл отдельным шагом перед сборкой, в git оставить
   пример со всеми ключами

Не сделано и остаётся проекту: раздача сборок тестерам (Firebase App
Distribution), загрузка в Google Play / TestFlight, подписанная iOS-сборка
(нужны сертификаты и профили Apple Developer), Shorebird в CI
(`SHOREBIRD_TOKEN`). В приватном репозитории macOS-минуты списываются с
коэффициентом 10 — iOS-джоб там стоит оставить ручным.

## 8. Остальное

- `README.md` — в нём та же шаблонная рамка, переписать под проект
- `android/key.properties` и keystore: `make setup-android`
- Deep links: файлы `apple-app-site-association` и `assetlinks.json` в шаблоне
  не поставляются, их нужно выложить на домен проекта
- Версия Flutter зафиксирована только в `.fvmrc` — `make shorebird-*` и CI
  читают её оттуда
