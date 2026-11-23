import 'package:client_api/client_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_starter/src/core/extension/extension.dart';
import 'package:flutter_starter/src/core/model/model.dart';
import 'package:flutter_starter/src/core/utils/logger.dart';

/// Выполняет сетевой вызов и приводит любую ошибку к типизированному
/// [AppException].
///
/// - [AppException] пробрасывается как есть — она уже типизирована;
/// - [DioException] разбирается через [DioX.throwCustom]: сеть, 401, отмена,
///   `message` с сервера ([fromMessage]) или [fallback];
/// - всё остальное (например, `TypeError` в маппере) логируется и
///   превращается в [fallback].
///
/// В репозитории оборачивается в приватный `_call`, который подставляет
/// исключение фичи:
///
/// ```dart
/// Future<T> _call<T>(UserErrorType type, Future<T> Function() body) =>
///     apiCall(
///       body,
///       fallback: UserException(type),
///       fromMessage: (message) => UserException(type, message),
///     );
/// ```
Future<T> apiCall<T, E extends AppException>(
  Future<T> Function() body, {
  required E fallback,
  required E Function(String message) fromMessage,
}) async {
  try {
    return await body();
  } on AppException {
    rethrow;
  } on DioException catch (error) {
    error.throwCustom(
      error.stackTrace,
      unknownError: fallback,
      errorBuilder: fromMessage,
    );
  } on Object catch (error, stackTrace) {
    // Без лога ошибка маппинга молча превратится в «не удалось загрузить»
    mainTalker.handle(error, stackTrace);
    Error.throwWithStackTrace(fallback, stackTrace);
  }
}

extension ApiResponseX<T> on ApiResponse<T> {
  /// [data] ответа; если его нет — `StateError`, который [apiCall]
  /// превратит в `fallback`.
  T requireData() => data ?? (throw StateError('ApiResponse.data is null'));
}
