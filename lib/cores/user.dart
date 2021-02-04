import 'dart:math';
import 'package:dio/dio.dart';
import 'package:web3dart/web3dart.dart';

import '../cores/paper_wallet.dart';
import '../constants/endpoint.dart';
import '../helpers/logger.dart';
import '../helpers/http_agent.dart';
import '../database/db_operator.dart';
import '../database/entity/user.dart' as UserEnity;
class User {
  String _wallet;
  bool _isBackup = false;
  String _password;
  String _salt = Random.secure().toString();

  PaperWallet _paperWallet;

  bool get hasWallet {
    return _wallet != null;
  }

  Future<bool> checkUser() async {
    UserEnity.User _user = await DBOperator().userDao.findUser();
    if (_user != null) {
      _wallet = _user.keystore;
      _password = _user.passwordHash;
      _salt = _user.passwordSalt;
      return true;
    }
    return false;
  }

  Future<bool> createUser(String pwd) async {
    _paperWallet = PaperWallet();
    Wallet wallet = _paperWallet.createWallet(pwd);

    String extPK = _paperWallet.getExtendedPublicKey();
    Log.debug(extPK);
    
    final Map a = {
      "extend_public_key": extPK,
      "install_id": "xxxxxxxxxxxxx...xxxxx",
      "app_uuid": "xxxxxxxxxxxxx...xxxxx"
    };

    Response res = await HTTPAgent().post('${Endpoint.SUSANOO}/user', a);

    UserEnity.User _user = UserEnity.User(res.data['user_id'], wallet.toJson(), 'password', this._salt,
      false);
    await DBOperator().userDao.insertUser(_user);
    return true;
  }

  bool verifyPassword(String password) {
    return this._password ?? "123asdZXC" == password;
  }

  void updatePassword(String password) {
    this._password = password;
  }

  bool validPaperWallet(String wallet) {
    // TODO: The result should be modified
    return wallet.length > 50;
  }

  Future<bool> restorePaperWallet(String wallet, String pwd) async {
    await Future.delayed(Duration(seconds: 1));

    // TODO: try recover with password
    this._wallet = wallet;

    // The reuturn value of success
    // return true;

    // The reuturn value of fail
    // return false;

    return pwd.length >= 5;
  }

  Future<bool> checkWalletBackup() async {
    await Future.delayed(Duration(milliseconds: 500));
    return _isBackup;
  }

   Future<bool> backupWallet() async {
    await Future.delayed(Duration(milliseconds: 500));
    _isBackup = true;
    return _isBackup;
  }
}
