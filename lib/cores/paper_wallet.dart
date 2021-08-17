import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:bip32/bip32.dart' as bip32;
import 'package:web3dart/web3dart.dart';
import 'package:convert/convert.dart';
// import 'package:bitcoins/bitcoins.dart' as bitcoins;

import '../models/credential.model.dart';
import '../helpers/logger.dart';
import '../helpers/cryptor.dart';
import '../helpers/rlp.dart' as rlp;

import 'signer.dart';
import 'user.dart';

class PaperWallet {
  static const String EXT_PATH = "m/84'/3324'/0'";
  static const int EXT_CHANGEINDEX = 0;
  static const int EXT_KEYINDEX = 0;

  static final PaperWallet _instance = PaperWallet._internal();
  factory PaperWallet() {
    return _instance;
  }
  PaperWallet._internal();

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

  String _getPassword(User user) {
    Uint8List userIdentifierBuffer = ascii.encode(user.thirdPartyId);
    Uint8List installIdBuffer = ascii.encode(user.installId);
    List<int> pwseedBuffer = Cryptor.keccak256round(Cryptor.keccak256round(
            Cryptor.keccak256round(userIdentifierBuffer, round: 1) +
                Cryptor.keccak256round(hex.decode(user.id), round: 1)) +
        Cryptor.keccak256round(Cryptor.keccak256round(
                rlp.toBuffer(
                    hex.encode(rlp.toBuffer(user.timestamp)).substring(3, 6)),
                round: 1) +
            Cryptor.keccak256round(installIdBuffer, round: 1)));
    String password = hex.encode(Cryptor.keccak256round(pwseedBuffer));
    return password;
  }

  Credential _generateCredentialData(User user) {
    Uint8List userIdentifierBuffer = ascii.encode(user.thirdPartyId);
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
            Cryptor.keccak256round(hex.decode(user.id), round: 1) +
                Cryptor.keccak256round(hex.decode(user.userSecret), round: 1)));
    String key = hex.encode(Cryptor.keccak256round(seedBuffer));
    String password = _getPassword(user);
    String extend = hex.encode(extendBuffer);

    return Credential(key: key, password: password, extend: extend);
  }

  List<int> _magicSeed(Uint8List pk) {
    if (pk.length < 64) {
      List<int> seed = Cryptor.keccak256round(pk, round: 2);

      String string = hex.encode(seed);
      Log.info('Seed: $string');

      return seed;
    }
    return pk;
  }

  Wallet _createWallet(Credential credential) {
    Random rng = Random.secure();
    EthPrivateKey credentials = EthPrivateKey.fromHex(credential.key);
    Wallet wallet = Wallet.createNew(credentials, credential.password, rng);
    return wallet;
  }

  Uint8List _getPrivKey(
    Wallet wallet,
    int changeIndex,
    int keyIndex, {
    String path = EXT_PATH,
    bool compressed = true,
  }) {
    List<int> seed = _magicSeed(wallet.privateKey.privateKey);
    Uint8List bytes = Uint8List.fromList(seed);
    bip32.BIP32 root = bip32.BIP32.fromSeed(bytes);
    bip32.BIP32 child = root.derivePath("$path/$changeIndex/$keyIndex");
    return child.privateKey!;
  }

  Wallet createWallet(User user) {
    Credential credential = this._generateCredentialData(user);
    Wallet wallet = _createWallet(credential);
    return wallet;
  }

  Wallet createWalletWithSeed(User user) {
    Credential credential = this._generateCredentialData(user);
    credential = credential.copyWith(key: hex.encode(user.seed));
    Wallet wallet = _createWallet(credential);
    return wallet;
  }

  Wallet jsonToWallet(String json, String password) =>
      Wallet.fromJson(json, password);

  String walletToJson({required Wallet wallet}) => wallet.toJson();

  Uint8List getPubKey(
    Wallet wallet,
    int changeIndex,
    int keyIndex, {
    String path = EXT_PATH,
    bool compressed = true,
  }) {
    List<int> seed = _magicSeed(wallet.privateKey.privateKey);
    Uint8List bytes = Uint8List.fromList(seed);
    bip32.BIP32 root = bip32.BIP32.fromSeed(bytes);
    bip32.BIP32 child = root.derivePath("$path/$changeIndex/$keyIndex");
    Uint8List publicKey = child.publicKey;
    Log.debug('compressed publicKey: ${hex.encode(publicKey)}');

    if (!compressed) {
      // TODO: Maybe we don't need uncompressed public key
      throw UnimplementedError('Implement on decorator');
    }
    return publicKey;
  }

  // see: https://iancoleman.io/bip39
  // see: https://learnmeabitcoin.com/technical/extended-keys
  String getExtendedPublicKey({
    required Wallet wallet,
    String path = EXT_PATH,
  }) {
    // const publicPrefix = [0x04, 0x88, 0xb2, 0x1e];
    const childNumber = 2147483648; // 2 ^ 31;
    List<int> seed = _magicSeed(wallet.privateKey.privateKey);

    Uint8List bytes = Uint8List.fromList(seed);
    var root = bip32.BIP32.fromSeed(bytes);
    var child = root.derivePath("$path");

    Uint8List publicKey = child.publicKey;

    final pub = bip32.BIP32.fromPublicKey(publicKey, child.chainCode);

    pub.depth = child.depth;
    pub.parentFingerprint = child.parentFingerprint;
    pub.index = childNumber;

    return pub.toBase58();
  }

  MsgSignature sign(
      {required Wallet wallet,
      required Uint8List data,
      required int changeIndex,
      required int keyIndex}) {
    Uint8List key = _getPrivKey(
      wallet,
      changeIndex,
      keyIndex,
    );
    MsgSignature signature = Signer().sign(data, key);
    return signature;
  }
}
