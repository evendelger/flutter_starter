import 'package:client_api/client_api.dart';
import 'package:flutter_starter/src/feature/user/model/user.dart';

extension UserApiMapper on UserDto {
  User toDomain() => User(
    id: id,
    name: name,
    phone: phone,
    avatar: avatar,
  );
}
