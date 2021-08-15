import 'dart:async';
import 'dart:typed_data';

import '../cores/user.dart';

class UserRepository {
  User? _user;

  User get user => _user!;

  set user(User user) => _user = user;

  Future<bool> createUser(String userIdentifier) async {
    List result = await User.createUser(userIdentifier);
    if (result[0]) user = result[1];
    return result[0];
  }

  Future<bool> createUserWithSeed(String userIdentifier, Uint8List seed) async {
    List result = await User.createUserWithSeed(userIdentifier, seed);
    if (result[0]) user = result[1];
    return result[0];
  }

  Future<bool> checkUser() async {
    List result = await User.checkUser();
    if (result[0]) user = result[1];
    return result[0];
  }

  Future<bool> deleteUser() => User.deleteUser();
}
