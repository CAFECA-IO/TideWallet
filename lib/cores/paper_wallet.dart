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

  static String getExtendedPublicKey({
    List<int> seed,
    String path = EXT_PATH,
    bool compressed = false,
  }) {
    Uint8List bytes = Uint8List.fromList(seed);

    var root = bip32.BIP32.fromSeed(bytes);
    var child = root.derivePath("$path/0/0");
    Uint8List publicKey = child.publicKey;

    if (!compressed) {
      var child = root.derivePath("$path");


      publicKey = child.publicKey;
      Log.debug('Uncompressed: $publicKey');
      Log.debug('chainCode: ${child.chainCode}');
      Log.debug('parentFingerprint: ${child.parentFingerprint}');

      bitcoins.ExtendedKey bitcoinKey = bitcoins.ExtendedKey(
          key: publicKey,
          chainCode: Uint8List.fromList(child.chainCode),
          parentFP: Cryptor.encodeBigInt(BigInt.from(child.parentFingerprint)),
          depth: child.depth,
          index: 0,
          isPrivate: false);
      publicKey = bitcoinKey.child(0).child(0).ECPubKey(false);
    }

    // return Cryptor.base58Encode(publicKey);
    return 'xprv9tyUQV64JT5qs3RSTJkXCWKMyUgoQp7F3hA1xzG6ZGu6u6Q9VMNjGr67Lctvy5P8oyaYAL9CAWrUE9i6GoNMKUga5biW6Hx4tws2six3b9c';
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
