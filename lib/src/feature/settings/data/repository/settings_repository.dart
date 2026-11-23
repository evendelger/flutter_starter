import 'package:flutter_starter/src/core/utils/device_app_info_service.dart';
import 'package:flutter_starter/src/core/utils/logger.dart';
import 'package:flutter_starter/src/feature/settings/database/settings_dao.dart';
import 'package:flutter_starter/src/feature/settings/enum/theme_type.dart';
import 'package:flutter_starter/src/feature/settings/model/settings_data.dart';

abstract interface class ISettingsRepository {
  /// Настройки, сохранённые на устройстве (читаются синхронно)
  SettingsData get defaultData;

  /// [defaultData] вместе с информацией о приложении и устройстве.
  /// Не бросает: если информацию получить не удалось, она остаётся `null`.
  Future<SettingsData> getData();

  Future<void> setTheme(AppThemeType value);
}

final class SettingsRepository implements ISettingsRepository {
  SettingsRepository({
    required this._settingsDao,
  });

  // TODO(template): тема по умолчанию светлая, потому что тёмной палитры
  // в шаблоне нет (`AppTheme.darkTheme` — заглушка). Когда тёмная тема
  // готова, сменить на `AppThemeType.system`.
  static const AppThemeType _defaultTheme = AppThemeType.light;

  final ISettingsDao _settingsDao;

  @override
  Future<void> setTheme(AppThemeType value) =>
      _settingsDao.themeMode.setValue(value.name);

  @override
  Future<SettingsData> getData() async {
    try {
      final appInfo = await DeviceAppInfoService.fetchAppDeviceInfo();
      return defaultData.copyWith(appInfo: appInfo);
    } on Object catch (error, stackTrace) {
      mainTalker.handle(error, stackTrace, 'Не удалось получить AppDeviceInfo');
      return defaultData;
    }
  }

  @override
  SettingsData get defaultData => SettingsData(
    themeType:
        AppThemeType.tryParse(_settingsDao.themeMode.value) ?? _defaultTheme,
  );
}
