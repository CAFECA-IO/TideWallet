import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:bip32/bip32.dart' as bip32;
import 'package:web3dart/web3dart.dart';
import 'package:convert/convert.dart';
// import 'package:bitcoins/bitcoins.dart' as bitcoins;

import '../helpers/logger.dart';
import '../helpers/cryptor.dart';
import '../models/credential.model.dart';

// import '../helpers/utils.dart';

class PaperWallet {
  static const String EXT_PATH = "m/84'/3324'/0'";
  static const int EXT_CHANGEINDEX = 0;
  static const int EXT_KEYINDEX = 0;

  PaperWallet();

  static Wallet createWallet(Credential credential) {
    Random rng = Random.secure();
    EthPrivateKey credentials = EthPrivateKey.fromHex(credential.key);
    Wallet wallet = Wallet.createNew(credentials, credential.password, rng);
    return wallet;
  }

  static Wallet recoverFromJson(String content, String pwd) {
    try {
      Wallet wallet = Wallet.fromJson(content, pwd);
      return wallet;
    } catch (e) {
      Log.warning(e);
      throw e;
    }
  }

  // param [
  //   Wallet: wallet
  //   String: password
  // ]
  static Wallet updatePassword(List param) {
    Wallet wallet = param[0];
    String password = param[1];
    EthPrivateKey fromHex =
        EthPrivateKey.fromHex(hex.encode(wallet.privateKey.privateKey));

    var rng = new Random.secure();

    final w = Wallet.createNew(fromHex, password, rng);

    return w;
  }

  //
  static List<int> magicSeed(Uint8List pk) {
    if (pk.length < 64) {
      List<int> seed = Cryptor.keccak256round(pk, round: 2);

      String string = hex.encode(seed);
      Log.info('Seed: $string');

      return seed;
    }
    return pk;
  }

  static Uint8List getPubKey(
    Wallet wallet,
    int changeIndex,
    int keyIndex, {
    String path = EXT_PATH,
    bool compressed = true,
  }) {
    List<int> seed = magicSeed(wallet.privateKey.privateKey);
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

  static Uint8List getPrivKey(
    Wallet wallet,
    int changeIndex,
    int keyIndex, {
    String path = EXT_PATH,
    bool compressed = true,
  }) {
    List<int> seed = magicSeed(wallet.privateKey.privateKey);
    Uint8List bytes = Uint8List.fromList(seed);
    bip32.BIP32 root = bip32.BIP32.fromSeed(bytes);
    bip32.BIP32 child = root.derivePath("$path/$changeIndex/$keyIndex");
    return child.privateKey!;
  }

  // see: https://iancoleman.io/bip39
  // see: https://learnmeabitcoin.com/technical/extended-keys
  static String getExtendedPublicKey({
    required Wallet wallet,
    String path = EXT_PATH,
  }) {
    // const publicPrefix = [0x04, 0x88, 0xb2, 0x1e];
    const childNumber = 2147483648; // 2 ^ 31;
    List<int> seed = magicSeed(wallet.privateKey.privateKey);

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

  // static String walletToJson(Wallet wallet) {
  static String walletToJson(Wallet wallet) {
    return wallet.toJson();
  }

  static Wallet jsonToWallet(String json, String password) {
    Wallet wallet;
    wallet = Wallet.fromJson(json, password);
    return wallet;
  }
}
