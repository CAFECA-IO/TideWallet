import 'dart:async';

import '../cores/user.dart';

class UserRepository {
  User _user = new User();

  User get user => _user;

  Future<void> createUser(String pwd) => _user.createUser(pwd);

  Future<bool> checkUser() => _user.checkUser();

  bool verifyPassword(String password) {
    return _user.verifyPassword(password);
  }

  void updatePassword(String password) {
    _user.updatePassword(password);
  }

  bool validPaperWallet(String wallet) {
    return _user.validPaperWallet(wallet);
  }

  Future<User> restorePaperWallet(String wallet, String pwd) async {
    final bool reault = await _user.restorePaperWallet(wallet, pwd);
    if (reault) {
      return _user;
    } else {
      return null;
    }
  }

  Future<bool> checkWalletBackup() => _user.checkWalletBackup();

  Future<bool> backupWallet() => _user.backupWallet();

  Future<String> getPaperWallet() async {
    await Future.delayed(Duration(milliseconds: 500));
    return 'wallet';
  }
}
