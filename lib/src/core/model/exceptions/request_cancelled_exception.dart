import 'package:flutter_starter/src/core/model/model.dart';

/// Запрос отменён (`CancelToken`, `restartable()` и т.п.).
///
/// Это не ошибка для пользователя: UI такое исключение не показывает.
final class RequestCancelledException implements AppException {
  const RequestCancelledException();
}
