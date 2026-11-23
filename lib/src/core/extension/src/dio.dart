import 'package:dio/dio.dart';
import 'package:flutter_starter/src/core/model/model.dart';

extension DioX on DioException {
  static const Set<DioExceptionType> _networkErrorTypes = {
    DioExceptionType.connectionError,
    DioExceptionType.connectionTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.badCertificate,
  };

  /// Превращает [DioException] в типизированное [AppException].
  ///
  /// Порядок проверок: отмена → сеть → 401 → `message` из тела ответа →
  /// [unknownError]. Статус 401 проверяется до разбора тела: многие серверы
  /// отдают его без тела или не в JSON.
  Never throwCustom<T extends Exception>(
    StackTrace stackTrace, {
    required T unknownError,
    required T Function(String message) errorBuilder,
  }) {
    if (type == DioExceptionType.cancel) {
      return Error.throwWithStackTrace(
        const RequestCancelledException(),
        stackTrace,
      );
    }

    if (_networkErrorTypes.contains(type)) {
      return Error.throwWithStackTrace(
        const NetworkException(),
        stackTrace,
      );
    }

    if (response?.statusCode == 401) {
      return Error.throwWithStackTrace(
        const UnauthorizedException(),
        stackTrace,
      );
    }

    final data = response?.data;
    // `message` бывает не строкой (например, в ответах валидации) —
    // тогда это неизвестная ошибка, а не TypeError
    final message = data is Map ? data['message'] : null;
    if (message is String && message.isNotEmpty) {
      return Error.throwWithStackTrace(errorBuilder(message), stackTrace);
    }

    return Error.throwWithStackTrace(unknownError, stackTrace);
  }
}
