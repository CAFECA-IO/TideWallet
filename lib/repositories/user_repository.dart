import 'dart:async';
import 'dart:typed_data';

import '../cores/user.dart';

class UserRepository {
  Future<bool> createUser(String userIdentifier) async {
    bool result = await UserCore().createUser(userIdentifier);
    return result;
  }

  Future<bool> createUserWithSeed(String userIdentifier, Uint8List seed) async {
    bool result = await UserCore().createUserWithSeed(userIdentifier, seed);
    return result;
  }

  Future<bool> checkUser() async {
    bool result = await UserCore().checkUser();
    return result;
  }

  Future<bool> deleteUser() => UserCore().deleteUser();
}
