import 'dart:async';
import 'dart:typed_data';

import '../cores/user.dart';

class UserRepository {
  Future<bool> createUser(String userIdentifier) async {
    bool result = await User.createUser(userIdentifier);
    return result;
  }

  Future<bool> createUserWithSeed(String userIdentifier, Uint8List seed) async {
    bool result = await User.createUserWithSeed(userIdentifier, seed);
    return result;
  }

  Future<bool> checkUser() async {
    bool result = await User.checkUser();
    return result;
  }

  Future<bool> deleteUser() => User.deleteUser();
}
