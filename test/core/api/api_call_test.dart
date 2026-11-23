import 'package:client_api/client_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_starter/src/core/api/api_call.dart';
import 'package:flutter_starter/src/core/model/model.dart';
import 'package:flutter_test/flutter_test.dart';

final class _TestException implements ApiException {
  const _TestException([this.message]);

  @override
  final String? message;
}

final _requestOptions = RequestOptions(path: '/test');

DioException _dioError({
  DioExceptionType type = DioExceptionType.badResponse,
  int? statusCode,
  Object? data,
}) => DioException(
  requestOptions: _requestOptions,
  type: type,
  response: statusCode == null && data == null
      ? null
      : Response<Object?>(
          requestOptions: _requestOptions,
          statusCode: statusCode,
          data: data,
        ),
);

Future<T> _call<T>(Future<T> Function() body) => apiCall(
  body,
  fallback: const _TestException(),
  fromMessage: _TestException.new,
);

Matcher _throwsTest({String? message}) => throwsA(
  isA<_TestException>().having((e) => e.message, 'message', message),
);

void main() {
  group('apiCall', () {
    test('возвращает результат успешного вызова', () async {
      expect(await _call(() async => 42), 42);
    });

    test('пробрасывает AppException как есть', () {
      expect(
        _call<void>(() async => throw const NetworkException()),
        throwsA(isA<NetworkException>()),
      );
    });

    test('прочие ошибки превращает в fallback', () {
      expect(
        _call<void>(() async => throw StateError('mapper')),
        _throwsTest(),
      );
    });

    test('requireData без data даёт fallback', () {
      expect(
        _call(() async => ApiResponse<int>().requireData()),
        _throwsTest(),
      );
    });
  });

  group('DioX.throwCustom через apiCall', () {
    Future<void> callWith(DioException error) => _call(() async => throw error);

    for (final type in [
      DioExceptionType.connectionError,
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.badCertificate,
    ]) {
      test('$type → NetworkException', () {
        expect(
          callWith(_dioError(type: type)),
          throwsA(isA<NetworkException>()),
        );
      });
    }

    test('cancel → RequestCancelledException', () {
      expect(
        callWith(_dioError(type: DioExceptionType.cancel)),
        throwsA(isA<RequestCancelledException>()),
      );
    });

    test('401 без тела → UnauthorizedException', () {
      expect(
        callWith(_dioError(statusCode: 401)),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('401 с телом не в JSON → UnauthorizedException', () {
      expect(
        callWith(_dioError(statusCode: 401, data: 'Unauthorized')),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('строковый message → исключение фичи с сообщением', () {
      expect(
        callWith(_dioError(statusCode: 400, data: {'message': 'Ошибка'})),
        _throwsTest(message: 'Ошибка'),
      );
    });

    test('message не строка → fallback, а не TypeError', () {
      expect(
        callWith(
          _dioError(
            statusCode: 422,
            data: {
              'message': {'email': 'invalid'},
            },
          ),
        ),
        _throwsTest(),
      );
    });

    test('пустой message → fallback', () {
      expect(
        callWith(_dioError(statusCode: 500, data: {'message': ''})),
        _throwsTest(),
      );
    });

    test('тело не Map → fallback', () {
      expect(
        callWith(_dioError(statusCode: 500, data: '<html>')),
        _throwsTest(),
      );
    });
  });
}
