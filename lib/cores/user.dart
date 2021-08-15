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

import 'tidewallet.dart';

class User {
  final String _id;
  final String _thirdPartyId;
  final String _installId;
  final int _timestamp;
  String? _userSecret;
  Uint8List? _seed;

  String get id => this._id;
  String get thirdPartyId => this._thirdPartyId;
  String get installId => this._installId;
  int get timestamp => this._timestamp;
  String get userSecret => this._userSecret!;
  Uint8List get seed => this._seed!;

  User({
    required String id,
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

  static Future<List> checkUser() async {
    UserEntity? user = await DBOperator().userDao.findUser();
    if (user != null) {
      User _user = User.fromUserEntity(user);
      _user._initUser();
      return [true, _user];
    }
    return [false];
  }

  static Future<List> createUser(String userIdentifier) async {
    Log.debug('createUser: $userIdentifier');

    String installId = await PrefManager().getInstallationId();
    Log.debug('installId: $installId');

    final List<String> user = await getUser(userIdentifier);
    final String userId = user[0];
    final String userSecret = user[1];
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    User _user = User(
        id: userId,
        thirdPartyId: userIdentifier,
        installId: installId,
        timestamp: timestamp,
        userSecret: userSecret);

    Wallet wallet = await compute(TideWallet().createWallet, _user);

    bool success = await _user._registerUser(wallet: wallet);

    return [success, _user];
  }

  static Future<List> createUserWithSeed(
      String userIdentifier, Uint8List seed) async {
    String installId = await PrefManager().getInstallationId();

    final List<String> user = await getUser(userIdentifier);
    final String userId = user[0];
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    User _user = User(
        id: userId,
        thirdPartyId: userIdentifier,
        installId: installId,
        timestamp: timestamp,
        seed: seed);

    Wallet wallet = await compute(TideWallet().createWalletWithSeed, _user);

    bool success = await _user._registerUser(wallet: wallet);

    return [success, _user];
  }

  static Future<List<String>> getUser(userIdentifier) async {
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

  Future<bool> _registerUser({
    required Wallet wallet,
  }) async {
    // String? fcmToken = await FCM().getToken();
    String extendPublicKey =
        await compute(TideWallet().extendedPublicKey, wallet);
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

      String keystore = await compute(TideWallet().keystore, wallet);

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

  Future<void> _initUser() async {
    AuthItem? item = await _prefManager.getAuthItem();
    if (item != null) {
      HTTPAgent().setToken(item.token);
    }
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
