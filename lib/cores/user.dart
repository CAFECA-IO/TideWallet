import 'dart:convert';
// import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:web3dart/web3dart.dart';
// import 'package:uuid/uuid.dart';
import 'package:convert/convert.dart';

import '../cores/paper_wallet.dart';
import '../constants/endpoint.dart';
import '../helpers/logger.dart';
import '../helpers/http_agent.dart';
import '../helpers/cryptor.dart';
import '../helpers/prefer_manager.dart';
import '../helpers/utils.dart';
import '../helpers/rlp.dart' as rlp;
import '../database/db_operator.dart';
import '../database/entity/user.dart';
import '../models/auth.model.dart';
import '../models/api_response.mode.dart';

class User {
  String _id;
  bool _isBackup = false;
  String _thirdPartyId;
  String _installId;
  int _timestamp;

  PrefManager _prefManager = PrefManager();

  String get id => _id;

  Future<bool> checkUser() async {
    UserEntity user = await DBOperator().userDao.findUser();
    if (user != null) {
      this._initUser(user);
      return true;
    }
    return false;
  }

  Uint8List _getNonce(Uint8List userIdentifierBuffer) {
    const int cafeca = 0xcafeca;
    int nonce = cafeca;
    String getString(nonce) {
      String result = hex
          .encode(Cryptor.keccak256round(
              (userIdentifierBuffer + rlp.toBuffer(nonce)),
              round: 1))
          .substring(0, 3)
          .toLowerCase();
      return result;
    }

    while (getString(nonce) != 'cfc') {
      nonce++;
    }
    return rlp.toBuffer(nonce);
  }

  String getPassword(
      {String userIdentifier, String userId, String installId, int timestamp}) {
    // ++ store in DB or app or storage ? [Emily 04/01/2021]
    Uint8List userIdentifierBuffer =
        ascii.encode(userIdentifier ?? this._thirdPartyId);
    Uint8List installIdBuffer = ascii.encode(installId ?? this._installId);
    Log.debug('userId: ${this._id}');
    List<int> pwseedBuffer = Cryptor.keccak256round(Cryptor.keccak256round(
            Cryptor.keccak256round(userIdentifierBuffer, round: 1) +
                Cryptor.keccak256round(hex.decode(userId ?? this._id),
                    round: 1)) +
        Cryptor.keccak256round(Cryptor.keccak256round(
                rlp.toBuffer(hex
                    .encode(rlp.toBuffer(timestamp ?? this._timestamp))
                    .substring(3, 6)),
                round: 1) +
            Cryptor.keccak256round(installIdBuffer, round: 1)));
    String password = hex.encode(Cryptor.keccak256round(pwseedBuffer));
    return password;
  }

  Map<String, String> _generateCredentialData(String userIdentifier,
      String userId, String userSecret, String installId, int timestamp) {
    Uint8List userIdentifierBuffer = ascii.encode(userIdentifier);
    Uint8List nonce = _getNonce(userIdentifierBuffer);
    Log.debug('nonce: $nonce');

    Uint8List mainBuffer =
        Uint8List.fromList((userIdentifierBuffer + nonce).sublist(0, 8));
    List<int> extendBuffer =
        Cryptor.keccak256round(nonce, round: 1).sublist(0, 4);
    List<int> seedBuffer = Cryptor.keccak256round(Cryptor.keccak256round(
            Cryptor.keccak256round(mainBuffer, round: 1) +
                Cryptor.keccak256round(extendBuffer, round: 1)) +
        Cryptor.keccak256round(
            Cryptor.keccak256round(hex.decode(userId), round: 1) +
                Cryptor.keccak256round(hex.decode(userSecret), round: 1)));
    String key = hex.encode(Cryptor.keccak256round(seedBuffer));
    String password = getPassword(
        userIdentifier: userIdentifier,
        userId: userId,
        installId: installId,
        timestamp: timestamp);
    String extend = hex.encode(extendBuffer);

    return {"key": key, "password": password, "extend": extend};
  }

  Future<bool> createUser(String userIdentifier) async {
    // ++ get userId & userSecret by providing Apple/Android ID from backend [Emily 04/01/2021]
    // -- mockup data
    String userId = randomHex(24);
    String userSecret = randomHex(24);
    // --
    String installId = await this._prefManager.getInstallationId();
    Log.debug('installId: $installId');

    int timestamp = DateTime.now().millisecondsSinceEpoch;
    Map<String, String> credentialData = _generateCredentialData(
        userIdentifier, userId, userSecret, installId, timestamp);

    Wallet wallet = await compute(PaperWallet.createWallet, credentialData);
    List<int> seed =
        await compute(PaperWallet.magicSeed, wallet.privateKey.privateKey);
    String extPK = PaperWallet.getExtendedPublicKey(seed: seed);

    final Map payload = {
      "wallet_name":
          "TideWallet3", // ++ inform backend to update [Emily 04/01/2021]
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
          // res.data['user_id'], // ++ inform backend to update userId become radom hex[Emily 04/01/2021]
          userId,
          keystore,
          userIdentifier,
          installId,
          timestamp,
          false);
      await DBOperator().userDao.insertUser(user);

      await this._initUser(user);
    }

    return res.success;
  }

  bool verifyPassword(String password) {
    // return _seasonedPassword(password) == this._passwordHash;
  }

  Future<bool> updatePassword(String oldPassword, String newpassword) async {
    UserEntity user = await DBOperator().userDao.findUser();

    final wallet = await this.restorePaperWallet(user.keystore, oldPassword);
    // final w = await compute(PaperWallet.updatePassword, [wallet, newpassword]);

    // final originSalt = this._salt;

    // this._salt = Random.secure().toString();
    // final passwordHash = _seasonedPassword(newpassword);
    // String keystore = await compute(PaperWallet.walletToJson, w);

    // final userUpdated = user.copyWith(
    //   keystore: keystore,
    //   passwordHash: passwordHash,
    //   passwordSalt: this._salt,
    //   backupStatus: false,
    // );

    // try {
    //   await DBOperator().userDao.updateUser(userUpdated);
    //   this._passwordHash = passwordHash;
    //   this._isBackup = false;

    //   return true;
    // } catch (e) {
    //   Log.error(e);
    //   this._salt = originSalt;

    //   return false;
    // }
  }

  bool validPaperWallet(String wallet) {
    try {
      Map v = json.decode(wallet);

      return v['crypto'] != null;
    } catch (e) {
      Log.warning(e);
    }

    return false;
  }

  Future<Wallet> restorePaperWallet(String keystore, String pwd) async {
    Wallet w = await compute(PaperWallet.jsonToWallet, [keystore, pwd]);

    return w;
  }

  Future<bool> restoreUser(Wallet wallet, String keystore, String pwd) async {
    List<int> seed =
        await compute(PaperWallet.magicSeed, wallet.privateKey.privateKey);
    String extPK = PaperWallet.getExtendedPublicKey(seed: seed);

    String installId = await this._prefManager.getInstallationId();
    // this._passwordHash = _seasonedPassword(pwd);

    final Map payload = {
      "wallet_name": 'Recover Wallet',
      "extend_public_key": extPK,
      "install_id": installId,
      "app_uuid": installId
    };

    APIResponse res =
        await HTTPAgent().post('${Endpoint.SUSANOO}/user', payload);

    if (res.success) {
      this._prefManager.setAuthItem(AuthItem.fromJson(res.data));

      // UserEntity user = UserEntity(
      //     res.data['user_id'], keystore, this._passwordHash, this._salt, false);
      // await DBOperator().userDao.insertUser(user);

      // await this._initUser(user);
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
    } catch (e) {
      Log.error(e);
    }

    return _isBackup;
  }

  Future<void> _initUser(UserEntity user) async {
    this._id = user.userId;
    this._thirdPartyId = user.thirdPartyId;
    this._installId = user.installId;
    this._timestamp = user.timestamp;
    this._isBackup = user.backupStatus;

    AuthItem item = await _prefManager.getAuthItem();
    if (item != null) {
      HTTPAgent().setToken(item.token);
    }
  }

  String _seasonedPassword(String password) {
    List<int> tmp = Cryptor.keccak256round(password.codeUnits, round: 3);
    // tmp += this._salt.codeUnits;
    // tmp = Cryptor.keccak256round(tmp, round: 1);

    Uint8List bytes = Uint8List.fromList(tmp);
    return String.fromCharCodes(bytes);
  }

  Future<String> getKeystore() async {
    final user = await DBOperator().userDao.findUser();

    return user?.keystore;
  }

  Future<bool> deleteUser() async {
    UserEntity user = await DBOperator().userDao.findUser();
    final item = await DBOperator().userDao.deleteUser(user);

    if (item < 0) return false;

    await this._prefManager.clearAll();
    return true;
  }
}
