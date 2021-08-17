import 'dart:typed_data';

import 'package:web3dart/web3dart.dart';

import '../database/entity/user.dart';

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
}
