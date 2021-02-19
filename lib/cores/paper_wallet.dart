import 'dart:math';
import 'dart:typed_data';
import 'package:bip32/bip32.dart' as bip32;
import 'package:web3dart/web3dart.dart';
import 'package:convert/convert.dart';
import 'package:bitcoins/bitcoins.dart';

import '../helpers/logger.dart';
import '../helpers/cryptor.dart';
import '../helpers/utils.dart';

class PaperWallet {
  static const String EXT_PATH = "m/44'/60'/0'";
  static const int EXT_CHAININDEX = 0;
  static const int EXT_KEYINDEX = 0;

  PaperWallet();

  static Wallet createWallet(String pwd) {
    Random rng = Random.secure();

    Credentials random = EthPrivateKey.createRandom(rng);
    Wallet wallet = Wallet.createNew(random, pwd, rng);
    Log.info(wallet.toJson());

    return wallet;
  }

  static Wallet recoverFromJson(String content, String pwd) {
    Wallet wallet;
    try {
      wallet = Wallet.fromJson(content, pwd);
    } catch (e) {
      Log.warning(e);
    }

    return wallet;
  }

  //
  static List<int> magicSeed(Uint8List pk) {
    List<int> seed = Cryptor.keccak256round(pk, round: 2);

    String string = hex.encode(seed);
    Log.info('Seed: $string');

    return seed;
  }

  static Future<Uint8List> getPubKey(
    Uint8List seed,
    int chainIndex,
    int keyIndex, {
    String path = EXT_PATH,
    bool compressed = true,
  }) async {
    Uint8List bytes = Uint8List.fromList(seed);
    bip32.BIP32 root = bip32.BIP32.fromSeed(bytes);
    bip32.BIP32 child = root.derivePath("$path/$chainIndex/$keyIndex");
    Uint8List publicKey = child.publicKey;
    Log.debug('compressed publicKey: ${hex.encode(publicKey)}');

    if (!compressed) {
      bip32.BIP32 child = root.derivePath("$path");
      publicKey = child.publicKey;
      ExtendedKey bitcoinKey = ExtendedKey(
          key: publicKey,
          chainCode: Uint8List.fromList(child.chainCode),
          parentFP: encodeBigInt(BigInt.from(child.parentFingerprint)),
          depth: child.depth,
          index: keyIndex != null ? keyIndex : 0,
          isPrivate: false);
      publicKey = bitcoinKey.child(chainIndex).child(keyIndex).ECPubKey(false);
      Log.debug('uncompressed publicKey: ${hex.encode(publicKey)}');
    }
    return publicKey;
  }

  static Future<Uint8List> getPrivKey(
    Uint8List seed,
    int chainIndex,
    int keyIndex, {
    String path = EXT_PATH,
    bool compressed = true,
  }) async {
    Uint8List bytes = Uint8List.fromList(seed);
    bip32.BIP32 root = bip32.BIP32.fromSeed(bytes);
    bip32.BIP32 child = root.derivePath("$path/$chainIndex/$keyIndex");
    return child.privateKey;
  }

  static String getExtendedPublicKey({
    List<int> seed,
    String path = EXT_PATH,
    bool compressed = true,
  }) {
    Uint8List bytes = Uint8List.fromList(seed);

    var root = bip32.BIP32.fromSeed(bytes);
    var child = root.derivePath("$path/0/0");
    Uint8List publicKey = child.publicKey;

    return hex.encode(publicKey);
  }

  static String walletToJson(Wallet wallet) {
    return wallet.toJson();
  }

  static Wallet jsonToWallet(List<String> decode) {
    final json = decode[0];
    final password = decode[1];
    Wallet wallet;
    try {
      wallet = Wallet.fromJson(json, password);
    } catch (e) {
      Log.error(e);
    }
    return wallet;
  }
}
