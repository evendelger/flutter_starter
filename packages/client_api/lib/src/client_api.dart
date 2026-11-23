import 'package:client_api/client_api.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'client_api.g.dart';

/// {@template client_api}
/// Dart REST API for client
/// {@endtemplate}
@RestApi()
abstract class ClientApi {
  /// {@macro client_api}
  factory ClientApi(
    Dio dio, {
    String? baseUrl,
  }) = _ClientApi;

  /// Войти в аккаунт
  @POST('/login')
  Future<ApiResponse<LoginResponse>> login({
    @Body() required LoginRequest request,
  });

  /// Зарегистрироваться
  @POST('/register')
  Future<ApiResponse<RegisterResponse>> register({
    @Body() required RegisterRequest request,
  });

  /// Получить данные пользователя
  @GET('/users/current')
  Future<ApiResponse<UserDto>> getUser();
}
