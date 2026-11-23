import 'package:client_api/client_api.dart';
import 'package:flutter_starter/src/core/api/api_call.dart';
import 'package:flutter_starter/src/feature/user/data/mappers/user_api_mapper.dart';
import 'package:flutter_starter/src/feature/user/database/dao/user_dao.dart';
import 'package:flutter_starter/src/feature/user/model/user.dart';
import 'package:flutter_starter/src/feature/user/model/user_exception.dart';

abstract interface class IUserRepository {
  Future<User> getUserData();
}

final class UserRepository implements IUserRepository {
  UserRepository({required this._userDao, required this._client});

  final IUserDao _userDao;

  final ClientApi _client;

  @override
  Future<User> getUserData() => _call(UserErrorType.getData, () async {
    final response = await _client.getUser();
    final user = response.requireData().toDomain();

    await _userDao.upsertUser(user);

    return user;
  });

  Future<T> _call<T>(UserErrorType type, Future<T> Function() body) => apiCall(
    body,
    fallback: UserException(type),
    fromMessage: (message) => UserException(type, message),
  );
}
