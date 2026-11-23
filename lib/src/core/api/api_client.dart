import 'package:dio/dio.dart';
import 'package:flutter_starter/src/core/constant/config.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

abstract interface class IApiClient {
  Dio get dio;
}

/// {@template api_client}
/// Конфигурация [Dio]: базовый URL, таймауты, заголовки, логирование.
///
/// Инстанс [dio] создаётся один раз — интерсепторы, добавленные к нему
/// (например, `AuthInterceptor`), видны всем, кто его использует.
/// {@endtemplate}
final class ApiClient implements IApiClient {
  /// {@macro api_client}
  ApiClient({
    required Talker talker,
    required String baseUrl,
  }) : dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: Config.connectionTimeout,
           receiveTimeout: Config.connectionTimeout,
           sendTimeout: Config.connectionTimeout,
           headers: {
             'Accept': 'application/json',
           },
           contentType: Headers.jsonContentType,
         ),
       ) {
    dio.interceptors.add(
      TalkerDioLogger(
        talker: talker,
        settings: const TalkerDioLoggerSettings(
          printErrorHeaders: false,
        ),
      ),
    );
  }

  @override
  final Dio dio;
}
