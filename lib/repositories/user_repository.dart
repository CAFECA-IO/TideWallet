import 'dart:async';
import 'dart:typed_data';
import 'package:web3dart/web3dart.dart';

import '../cores/user.dart';

class UserRepository {
  User _user = new User();

  User get user => _user;

  Future<bool> createUser(String userIdentifier) =>
      _user.createUser(userIdentifier);

  Future<bool> createUserWithSeed(String userIdentifier, Uint8List seed) =>
      _user.createUserWithSeed(userIdentifier, seed);

  Future<bool> checkUser() => _user.checkUser();

  Future<bool> checkWalletBackup() => _user.checkWalletBackup();

  Future<bool> backupWallet() => _user.backupWallet();

  Future<String> getPaperWallet() => user.getKeystore();
  String getPassword() => user.getPassword();

  Future<bool> deleteUser() => user.deleteUser();
}
