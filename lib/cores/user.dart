import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:web3dart/web3dart.dart';

import '../cores/paper_wallet.dart';
import '../constants/endpoint.dart';
import '../helpers/logger.dart';
import '../helpers/http_agent.dart';
import '../helpers/cryptor.dart';
import '../helpers/prefer_manager.dart';
import '../database/db_operator.dart';
import '../database/entity/user.dart';
import '../models/auth.model.dart';
import '../models/api_response.mode.dart';

class User {
  String _id;
  Wallet _wallet;
  bool _isBackup = false;
  String _passwordHash;
  String _salt = Random.secure().toString();

  PrefManager _prefManager = PrefManager();

  String get id => _id;

  // Deprecated
  bool get hasWallet {
    return _wallet != null;
  }

  Future<bool> checkUser() async {
    UserEntity user = await DBOperator().userDao.findUser();
    if (user != null) {
      this._initUser(user);
      return true;
    }
    return false;
  }

  Future<bool> createUser(String pwd, String walletName) async {
    Wallet wallet = await compute(PaperWallet.createWallet, pwd);
    List<int> seed =
        await compute(PaperWallet.magicSeed, wallet.privateKey.privateKey);
    String extPK = PaperWallet.getExtendedPublicKey(seed: seed);

    String installId = await this._prefManager.getInstallationId();

    this._passwordHash = _seasonedPassword(pwd);

    final Map payload = {
      "wallet_name": walletName,
      "extend_public_key": extPK,
      "install_id": installId,
      "app_uuid": installId
    };

    APIResponse res =
        await HTTPAgent().post('${Endpoint.SUSANOO}/user', payload);

    if (res.success) {
      this._prefManager.setAuthItem(AuthItem.fromJson(res.data));

      String keystore = await compute(PaperWallet.walletToJson, wallet);

      UserEntity user = UserEntity(
          res.data['user_id'], keystore, this._passwordHash, this._salt, false);
      await DBOperator().userDao.insertUser(user);

      await this._initUser(user);
      this._wallet = wallet;
    }

    return res.success;
  }

  bool verifyPassword(String password) {
    return _seasonedPassword(password) == this._passwordHash;
  }

  void updatePassword(String password) {
    this._passwordHash = _seasonedPassword(password);
  }

  bool validPaperWallet(String wallet) {
    try {
      Map v = json.decode(wallet);

      return v['address'] != null && v['crypto'] != null;
    } catch (e) {
      Log.warning(e);
    }

    return false;
  }

  Future<bool> restorePaperWallet(String wallet, String pwd) async {
    Wallet w = await compute(PaperWallet.jsonToWallet, [wallet, pwd]);

    if (w == null) {
      return false;
    }
    List<int> seed =
        await compute(PaperWallet.magicSeed, w.privateKey.privateKey);
    String extPK = PaperWallet.getExtendedPublicKey(seed: seed);

    String installId = await this._prefManager.getInstallationId();
    this._passwordHash = _seasonedPassword(pwd);

    final Map payload = {
      "wallet_name": '',
      "extend_public_key": extPK,
      "install_id": installId,
      "app_uuid": installId
    };

    APIResponse res =
        await HTTPAgent().post('${Endpoint.SUSANOO}/user', payload);

    if (res.success) {
      this._prefManager.setAuthItem(AuthItem.fromJson(res.data));

      UserEntity user = UserEntity(
          res.data['user_id'], wallet, this._passwordHash, this._salt, false);
      await DBOperator().userDao.insertUser(user);

      await this._initUser(user);
      this._wallet = w;
    }

    return res.success;
  }

  Future<bool> checkWalletBackup() async {
    UserEntity _user = await DBOperator().userDao.findUser();
    if (_user != null) {
      return _user.backupStatus;
    }
    return false;
  }

  Future<bool> backupWallet() async {
    try {
      UserEntity _user = await DBOperator().userDao.findUser();

      await DBOperator().userDao.updateUser(_user.copyWith(backupStatus: true));
      _isBackup = true;
    } catch(e) {
      Log.error(e);
    }

    return _isBackup;
  }

  Future<void> _initUser(UserEntity user) async {
    this._id = user.userId;
    this._passwordHash = user.passwordHash;
    this._salt = user.passwordSalt;
    this._isBackup = user.backupStatus;

    Log.debug('ID ${this._id}');

    AuthItem item = await _prefManager.getAuthItem();
    if (item != null) {
      HTTPAgent().setToken(item.token);
    }
  }

  String _seasonedPassword(String password) {
    List<int> tmp = Cryptor.keccak256round(password.codeUnits, round: 3);
    tmp += this._salt.codeUnits;
    tmp = Cryptor.keccak256round(tmp, round: 1);

    Uint8List bytes = Uint8List.fromList(tmp);
    return String.fromCharCodes(bytes);
  }

  Uint8List getPrivateKey() {
    if (_wallet != null) {
      return _wallet.privateKey.privateKey;
    }

    return null;
  }

  Future<String> getKeystore() async {
    final user = await DBOperator().userDao.findUser();

    return user?.keystore;
  }
}
