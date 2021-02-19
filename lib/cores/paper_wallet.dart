import 'dart:math';
import 'dart:typed_data';
import 'package:bip32/bip32.dart' as bip32;
import 'package:web3dart/web3dart.dart';
import "package:hex/hex.dart";
import 'package:bitcoins/bitcoins.dart' as bitcoins;

import '../helpers/logger.dart';
import '../helpers/cryptor.dart';

class PaperWallet {
  static const String EXT_PATH = "m/44'/0'/0'";
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

    String string = HEX.encode(seed);
    Log.info('Seed: $string');

    return seed;
  }

  static Future<Uint8List> getPubKey(
    Uint8List seed,
    int changeIndex,
    int keyIndex, {
    String path = EXT_PATH,
    bool compressed = true,
  }) async {
    Uint8List bytes = Uint8List.fromList(seed);
    bip32.BIP32 root = bip32.BIP32.fromSeed(bytes);
    bip32.BIP32 child = root.derivePath("$path/$changeIndex/$keyIndex");
    return child.publicKey;
  }

  static Future<Uint8List> getPrivKey(
    Uint8List seed,
    int changeIndex,
    int keyIndex, {
    String path = EXT_PATH,
    bool compressed = true,
  }) async {
    Uint8List bytes = Uint8List.fromList(seed);
    bip32.BIP32 root = bip32.BIP32.fromSeed(bytes);
    bip32.BIP32 child = root.derivePath("$path/$changeIndex/$keyIndex");
    return child.privateKey;
  }

  // see: https://iancoleman.io/bip39
  // see: https://learnmeabitcoin.com/technical/extended-keys
  static String getExtendedPublicKey({
    List<int> seed,
    String path = EXT_PATH,
  }) {
    const publicPrefix = [0x04, 0x88, 0xb2, 0x1e];
    const childNumber = 2147483648; // 2 ^ 31;
    Uint8List bytes = Uint8List.fromList(seed);

    var root = bip32.BIP32.fromSeed(bytes);
    var child = root.derivePath("$path");
    Uint8List publicKey = child.publicKey;

    bitcoins.ExtendedKey bitcoinKey = bitcoins.ExtendedKey(
      key: publicKey,
      chainCode: Uint8List.fromList(child.chainCode),
      parentFP: Cryptor.encodeBigInt(BigInt.from(child.parentFingerprint)),
      depth: child.depth,
      index: childNumber,
      isPrivate: false,
    );
    final serialization =
        bitcoinKey.toBase58(Uint8List.fromList(publicPrefix));

    return serialization;
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
