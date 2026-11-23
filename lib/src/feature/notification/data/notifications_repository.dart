/// {@template notifications_repository}
/// Регистрация push-токена устройства на сервере.
///
/// Модуль уведомлений в шаблоне не подключён (см. `MainRunner.run()`),
/// поэтому методы — заглушки.
/// {@endtemplate}
abstract interface class INotificationsRepository {
  /// Отправить push-токен на сервер; без [token] берётся текущий токен FCM
  Future<void> registerPushToken({String? token});

  /// Удалить push-токен устройства на сервере (например, при выходе)
  Future<void> deletePushToken();
}

/// {@macro notifications_repository}
final class NotificationsRepository implements INotificationsRepository {
  /// {@macro notifications_repository}
  const NotificationsRepository();

  // TODO(template): добавить эндпоинты регистрации и удаления токена
  // в `ClientApi`, принять `ClientApi` в конструкторе и вызвать их через
  // `apiCall`. Токен — `FirebaseMessaging.instance.getToken()`, модель
  // устройства и версия приложения — `DeviceAppInfoService`.
  @override
  Future<void> registerPushToken({String? token}) async {}

  @override
  Future<void> deletePushToken() async {}
}
