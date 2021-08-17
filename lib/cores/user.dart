import 'dart:typed_data';

import '../constants/endpoint.dart';
import '../helpers/logger.dart';
import '../helpers/http_agent.dart';
import '../helpers/prefer_manager.dart';
import '../database/db_operator.dart';
import '../database/entity/user.dart';
import '../models/user.model.dart';
import '../models/auth.model.dart';
import '../models/api_response.mode.dart';
// import '../services/fcm_service.dart';

import 'paper_wallet.dart';

class UserCore {
  static final _instance = UserCore._internal();
  factory UserCore() {
    return _instance;
  }
  UserCore._internal();
  PrefManager _prefManager = PrefManager();

  Future<void> _setHttpToken() async {
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

  Future<bool> checkUser() async {
    UserEntity? user = await DBOperator().userDao.findUser();
    if (user != null) {
      _setHttpToken();
      return true;
    }
    return false;
  }

  Future<bool> createUser(String userIdentifier) async {
    Log.debug('createUser: $userIdentifier');

    String installId = await _prefManager.getInstallationId();
    Log.debug('installId: $installId');
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    User _user = User(
        thirdPartyId: userIdentifier,
        installId: installId,
        timestamp: timestamp);

    final List<String> user = await _getUser(userIdentifier);
    _user.userId = user[0];
    _user.userSecret = user[1];

    _user.wallet = PaperWalletCore().createWallet(_user);

    bool success = await _registerUser(_user);

    return success;
  }

  Future<bool> createUserWithSeed(String userIdentifier, Uint8List seed) async {
    String installId = await _prefManager.getInstallationId();
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    User _user = User(
        thirdPartyId: userIdentifier,
        installId: installId,
        timestamp: timestamp,
        seed: seed);
    final List<String> user = await _getUser(userIdentifier);

    _user.userId = user[0];
    _user.wallet = PaperWalletCore().createWalletWithSeed(_user);

    bool success = await _registerUser(_user);

    return success;
  }

  Future<bool> _registerUser(User user) async {
    // String? fcmToken = await FCM().getToken();
    String extendPublicKey =
        PaperWalletCore().getExtendedPublicKey(wallet: user.wallet);
    final Map payload = {
      "wallet_name":
          "TideWallet3", // -- we dont provide user to set wallet anymore
      "extend_public_key": extendPublicKey,
      "install_id": user.installId,
      "app_uuid": user.installId,
      // "fcm_token": fcmToken
    };

    APIResponse res = await HTTPAgent().post('${Endpoint.url}/user', payload);

    if (res.success) {
      _prefManager.setAuthItem(AuthItem.fromJson(res.data));

      // -- debugInfo
      Log.info('_registerUser token: ${res.data["token"]}');
      Log.info('_registerUser tokenSecret: ${res.data["tokenSecret"]}');
      // -- debugInfo

      String keystore = PaperWalletCore().walletToJson(wallet: user.wallet);

      UserEntity userEntity = UserEntity(
          userId: user.id,
          thirdPartyId: user.thirdPartyId,
          keystore: keystore,
          installId: user.installId,
          timestamp: user.timestamp);
      await DBOperator().userDao.insertUser(userEntity);
      await this._setHttpToken();
    }

    return res.success;
  }

  Future<bool> deleteUser() async {
    UserEntity? user = await DBOperator().userDao.findUser();
    int item;
    if (user != null)
      item = await DBOperator().userDao.deleteUser(user);
    else
      return true;
    if (item < 0) return false;

    await _prefManager.clearAll();
    return true;
  }
}
