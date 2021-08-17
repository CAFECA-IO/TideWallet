import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'package:web3dart/web3dart.dart';

import '../constants/endpoint.dart';
import '../helpers/logger.dart';
import '../helpers/http_agent.dart';
import '../helpers/prefer_manager.dart';
import '../database/db_operator.dart';
import '../database/entity/user.dart';
import '../models/auth.model.dart';
import '../models/api_response.mode.dart';
// import '../services/fcm_service.dart';

import 'paper_wallet.dart';

class User {
  String? _id;
  final String _thirdPartyId;
  final String _installId;
  final int _timestamp;
  String? _userSecret;
  Uint8List? _seed;
  Wallet? _wallet;

  String get id => this._id!;
  String get thirdPartyId => this._thirdPartyId;
  String get installId => this._installId;
  int get timestamp => this._timestamp;
  String get userSecret => this._userSecret!;
  Uint8List get seed => this._seed!;
  Wallet get wallet => this._wallet!;

  set userId(String userId) => this._id = userId;
  set userSecret(String userSecret) => this._userSecret = userSecret;
  set seed(Uint8List seed) => this._seed = seed;
  set wallet(Wallet wallet) => this._wallet = wallet;

  User({
    String? id,
    required String thirdPartyId,
    required String installId,
    required int timestamp,
    String? userSecret,
    Uint8List? seed,
  })  : this._id = id,
        this._thirdPartyId = thirdPartyId,
        this._installId = installId,
        this._timestamp = timestamp,
        this._userSecret = userSecret,
        this._seed = seed;

  User.fromUserEntity(UserEntity user)
      : this._id = user.userId,
        this._thirdPartyId = user.thirdPartyId,
        this._installId = user.installId,
        this._timestamp = user.timestamp;

  PrefManager _prefManager = PrefManager();

  static Future<bool> checkUser() async {
    UserEntity? user = await DBOperator().userDao.findUser();
    if (user != null) {
      User _user = User.fromUserEntity(user);
      _user._initUser();
      return true;
    }
    return false;
  }

  static Future<bool> createUser(String userIdentifier) async {
    Log.debug('createUser: $userIdentifier');

    String installId = await PrefManager().getInstallationId();
    Log.debug('installId: $installId');
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    User _user = User(
        thirdPartyId: userIdentifier,
        installId: installId,
        timestamp: timestamp);

    final List<String> user = await _user._getUser(userIdentifier);
    _user.userId = user[0];
    _user.userSecret = user[1];

    _user.wallet = PaperWallet().createWallet(_user);

    bool success = await _user._registerUser();

    return success;
  }

  static Future<bool> createUserWithSeed(
      String userIdentifier, Uint8List seed) async {
    String installId = await PrefManager().getInstallationId();
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    User _user = User(
        thirdPartyId: userIdentifier,
        installId: installId,
        timestamp: timestamp,
        seed: seed);
    final List<String> user = await _user._getUser(userIdentifier);

    _user.userId = user[0];
    _user.wallet = PaperWallet().createWalletWithSeed(_user);

    bool success = await _user._registerUser();

    return success;
  }

  Future<void> _initUser() async {
    AuthItem? item = await _prefManager.getAuthItem();
    if (item != null) {
      HTTPAgent().setToken(item.token);
    }
  }

  Future<List<String>> _getUser(userIdentifier) async {
    String userId;
    String userSecret;

    APIResponse _res = await HTTPAgent()
        .post(Endpoint.url + '/user/id', {"id": userIdentifier});
    if (_res.success) {
      Log.debug('_res.data: ${_res.data}');
      userId = _res.data['user_id'];
      userSecret = _res.data['user_secret'];

      return [userId, userSecret];
    } else {
      return [];
    }
  }

  Future<bool> _registerUser() async {
    // String? fcmToken = await FCM().getToken();
    String extendPublicKey =
        PaperWallet().getExtendedPublicKey(wallet: this.wallet);
    final Map payload = {
      "wallet_name":
          "TideWallet3", // -- we dont provide user to set wallet anymore
      "extend_public_key": extendPublicKey,
      "install_id": installId,
      "app_uuid": installId,
      // "fcm_token": fcmToken
    };

    APIResponse res = await HTTPAgent().post('${Endpoint.url}/user', payload);

    if (res.success) {
      this._prefManager.setAuthItem(AuthItem.fromJson(res.data));

      // -- debugInfo
      Log.info('_registerUser token: ${res.data["token"]}');
      Log.info('_registerUser tokenSecret: ${res.data["tokenSecret"]}');
      // -- debugInfo

      String keystore = PaperWallet().walletToJson(wallet: this.wallet);

      UserEntity userEntity = UserEntity(
          userId: this.id,
          thirdPartyId: this.thirdPartyId,
          keystore: keystore,
          installId: installId,
          timestamp: timestamp);
      await DBOperator().userDao.insertUser(userEntity);
      await this._initUser();
    }

    return res.success;
  }

  static Future<bool> deleteUser() async {
    UserEntity? user = await DBOperator().userDao.findUser();
    int item;
    if (user != null)
      item = await DBOperator().userDao.deleteUser(user);
    else
      return true;
    if (item < 0) return false;

    await PrefManager().clearAll();
    return true;
  }
}
