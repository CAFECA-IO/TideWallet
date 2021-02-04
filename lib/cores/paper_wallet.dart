import 'dart:math';
import 'dart:typed_data';
import 'package:bip32/bip32.dart' as bip32;
import 'package:web3dart/web3dart.dart';

import '../helpers/logger.dart';
import '../helpers/cryptor.dart';

class PaperWallet {
  static const String EXT_PATH = "m/44'/0'/0'";
  static const int EXT_CHAININDEX = 0;
  static const int EXT_KEYINDEX = 0;

  List<int> _seed;

  PaperWallet();

  Wallet createWallet(String pwd) {
    Random rng = Random.secure();

    Credentials random = EthPrivateKey.createRandom(rng);
    Wallet wallet = Wallet.createNew(random, pwd, rng);
    Log.info(wallet.toJson());

    Log.debug(wallet.privateKey.toString());
    _magicSeed(wallet.privateKey.toString());

    return wallet;
  }

  Wallet recoverFromJson(String content, String pwd) {
    Wallet wallet;
    try {
      wallet = Wallet.fromJson(content, pwd);
    } catch (e) {
      Log.warning(e);
    }

    return wallet;
  }

  //
  void _magicSeed(String pk) {
    List<int> list = pk.codeUnits;
    Uint8List bytes = Uint8List.fromList(list);
    List<int> seed = Cryptor.sha256round(bytes, round: 2);
    this._seed = seed;

    Uint8List seedBytes = Uint8List.fromList(this._seed);
    String string = String.fromCharCodes(seedBytes);
    Log.info('Seed: $string');
  }


  String getExtendedPublicKey({
    String path = EXT_PATH,
    int chainIndex = EXT_CHAININDEX,
    int keyIndex = EXT_KEYINDEX,
    bool compressed = true,
  }) {
    Uint8List bytes = Uint8List.fromList(this._seed);

    var root = bip32.BIP32.fromSeed(bytes);
    var child = root.derivePath("$path/$chainIndex/$keyIndex");
    Uint8List publicKey = child.publicKey;

    if (!compressed) {
      // var child = root.derivePath("$path");

      // publicKey = child.publicKey;
      // bitcoins.ExtendedKey bitcoinKey = bitcoins.ExtendedKey(
      //     key: publicKey,
      //     chainCode: Uint8List.fromList(child.chainCode),
      //     parentFP: encodeBigInt(BigInt.from(child.parentFingerprint)),
      //     depth: child.depth,
      //     index: keyIndex != null ? keyIndex : 0,
      //     isPrivate: false);
      // publicKey = bitcoinKey.child(chainIndex).child(keyIndex).ECPubKey(false);
    }
    return String.fromCharCodes(publicKey);
  }
}
