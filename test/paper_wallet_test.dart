import "package:hex/hex.dart";

import 'package:flutter_test/flutter_test.dart';
import 'package:tidewallet3/cores/paper_wallet.dart';
import 'package:tidewallet3/helpers/logger.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  const String pwd = 'Paul12345';
  group('Paper Wallet', () {
    Wallet wallet;
    test('create', () {
      wallet = PaperWallet.createWallet(pwd);
      Wallet _w = PaperWallet.recoverFromJson(wallet.toJson(), pwd);

      expect(wallet.toJson(), _w.toJson());
    });

    test('recover with wrong password', () {
      Wallet _w = PaperWallet.recoverFromJson(wallet.toJson(), '12345');

      expect(_w, null);
    });

    test('seed', () {
      const String privateKey = '929cb0a76cccbb93283832c5833d53ce7048c085648eb367a9e63c44c146b35d';
      const String expectSeed = '35f8af7f1bdb4c53446f43c6f22ba0b525634ab556229fffd0f1813cc75b3a2c';
      var seed = PaperWallet.magicSeed(HEX.decode(privateKey));

      expect(HEX.encode(seed), expectSeed);
    });

    test('extended public key', () {
      String seed = '35f8af7f1bdb4c53446f43c6f22ba0b525634ab556229fffd0f1813cc75b3a2c';
      String key = PaperWallet.getExtendedPublicKey(seed: HEX.decode(seed));

      const String expectKey = '037f5ac62a8918aca303c20a1b7c458627f641875e4a9f8cff6b8a850281296576';
      Log.info(key);

      expect(key, expectKey);
    });
  });
}
