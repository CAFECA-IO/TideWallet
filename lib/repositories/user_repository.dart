import 'dart:async';
import 'package:web3dart/web3dart.dart';

import '../cores/user.dart';

class UserRepository {
  User _user = new User();

  User get user => _user;

  Future<bool> createUser(String pwd, String walletName) =>
      _user.createUser(pwd, walletName);

  Future<bool> checkUser() => _user.checkUser();

  bool verifyPassword(String password) {
    return _user.verifyPassword(password);
  }

  Future<bool> updatePassword(String old, String password) => _user.updatePassword(old, password);

  bool validPaperWallet(String wallet) {
    return _user.validPaperWallet(wallet);
  }

  Future<Wallet> restorePaperWallet(String wallet, String pwd) => _user.restorePaperWallet(wallet, pwd);

  Future<User> restoreUser(Wallet wallet, String keystore, String pwd) async {
    final bool reault = await _user.restoreUser(wallet, keystore, pwd);
    if (reault) {
      return _user;
    } else {
      return null;
    }
  }

  Future<bool> checkWalletBackup() => _user.checkWalletBackup();

  Future<bool> backupWallet() => _user.backupWallet();

  Future<String> getPaperWallet() => user.getKeystore();

  Future<bool> deleteUser() => user.deleteUser();
}
