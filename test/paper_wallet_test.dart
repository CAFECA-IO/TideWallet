import 'package:flutter_test/flutter_test.dart';
import 'package:tidewallet3/cores/paper_wallet.dart';
import 'package:tidewallet3/helpers/logger.dart';
import 'package:web3dart/web3dart.dart';
import 'package:convert/convert.dart';

void main() {
  const String pwd = 'Paul12345';
  group('Paper Wallet', () {
    Wallet wallet;
    test('create', () {
      wallet = PaperWallet.createWallet(pwd);
      Wallet _w = PaperWallet.recoverFromJson(wallet.toJson(), pwd);

      expect(wallet.toJson(), _w.toJson());
    });

    test('update password', () {
      final pwd = 'Paul123456';
      final expectOrigin = wallet;

      final keystore = PaperWallet.updatePassword([expectOrigin, pwd]);

      Wallet w = PaperWallet.recoverFromJson(keystore.toJson(), pwd);

      expect(expectOrigin.toJson(), isNot(equals(w.toJson())));
      expect(expectOrigin.privateKey.privateKey, w.privateKey.privateKey);
    });

    test('recover with wrong password', () {
      Wallet _w = PaperWallet.recoverFromJson(wallet.toJson(), '12345');

      expect(_w, null);
    });

    test('seed', () {
      const String privateKey =
          '929cb0a76cccbb93283832c5833d53ce7048c085648eb367a9e63c44c146b35d';
      const String expectSeed =
          '35f8af7f1bdb4c53446f43c6f22ba0b525634ab556229fffd0f1813cc75b3a2c';
      var seed = PaperWallet.magicSeed(hex.decode(privateKey));

      expect(hex.encode(seed), expectSeed);
    });

    test('extended public key', () {
      String seed =
          '35f8af7f1bdb4c53446f43c6f22ba0b525634ab556229fffd0f1813cc75b3a2c';
      String key = PaperWallet.getExtendedPublicKey(seed: hex.decode(seed));

      const String expectKey =
          'xpub6BkDbi1YizgiJtXySxhdKVXruzsgB8E3pERHXL9GAwHdo2dMSkHCndsvdvoKdFQTdwqcRtqrDxbKszYLdcsX8Hk9f9XbdgQ1vHb1N9ASxtr';
      expect(key, expectKey);
    });
  });
}
