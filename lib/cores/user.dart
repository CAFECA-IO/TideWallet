import 'dart:math';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:web3dart/web3dart.dart';

import '../cores/paper_wallet.dart';
import '../constants/endpoint.dart';
import '../helpers/logger.dart';
import '../helpers/http_agent.dart';
import '../helpers/cryptor.dart';
import '../helpers/prefer_manager.dart';
import '../database/db_operator.dart';
import '../database/entity/user.dart' as UserEnity;
import '../models/auth.model.dart';

class User {
  String _wallet;
  bool _isBackup = false;
  String _passwordHash;
  String _salt = Random.secure().toString();

  PaperWallet _paperWallet;
  PrefManager _prefManager = PrefManager();

  // Deprecated
  bool get hasWallet {
    return _wallet != null;
  }

  Future<bool> checkUser() async {
    UserEnity.User user = await DBOperator().userDao.findUser();
    if (user != null) {
      this._initUser(user);
      return true;
    }
    return false;
  }

  Future<bool> createUser(String pwd) async {
    _paperWallet = PaperWallet();
    Wallet wallet = _paperWallet.createWallet(pwd);
    String extPK = _paperWallet.getExtendedPublicKey();
    Log.debug(extPK);

    String installId = await this._prefManager.getInstallationId();

    this._passwordHash = _seasonedPassword(pwd);

    final Map payload = {
      "extend_public_key": extPK,
      "install_id": installId,
      "app_uuid": installId
    };

    Response res = await HTTPAgent().post('${Endpoint.SUSANOO}/user', payload);
    Map data = res.data['payload'];
    this._prefManager.setAuthItem(AuthItem.fromJson(data));

    UserEnity.User user = UserEnity.User(data['user_id'], wallet.toJson(),
        this._passwordHash, this._salt, false);
    await DBOperator().userDao.insertUser(user);
    await this._initUser(user);

    // TODO
    return res.data['success'];
  }

  bool verifyPassword(String password) {
    return _seasonedPassword(password) == this._passwordHash;
  }

  void updatePassword(String password) {
    this._passwordHash = _seasonedPassword(password);
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
    UserEnity.User _user = await DBOperator().userDao.findUser();
    if (_user != null) {
      return _user.backupStatus;
    }
    return false;
  }

  Future<bool> backupWallet() async {
    await Future.delayed(Duration(milliseconds: 500));
    _isBackup = true;
    return _isBackup;
  }

  Future<void> _initUser(UserEnity.User user) async {
    this._wallet = user.keystore;
    this._passwordHash = user.passwordHash;
    this._salt = user.passwordSalt;
    this._isBackup = user.backupStatus;

    AuthItem item = await _prefManager.getAuthItem();
    if (item != null) {
      HTTPAgent().setToken(item.token);
    }
  }

  String _seasonedPassword(String password) {
    List<int> tmp = Cryptor.sha256round(password.codeUnits, round: 3);
    tmp += this._salt.codeUnits;
    tmp = Cryptor.sha256round(tmp, round: 1);

    Uint8List bytes = Uint8List.fromList(tmp);
    return String.fromCharCodes(bytes);
  }
}
