import 'package:flutter_test/flutter_test.dart';
import 'package:web3dart/web3dart.dart';
import '../lib/cores/paper_wallet.dart';

void main() {
  const String pwd = 'Paul12345';
  group('Paper Wallet', () {
    PaperWallet paperWallet = PaperWallet();
    Wallet wallet;
    test('create', () {
      wallet = paperWallet.createWallet(pwd);
      Wallet _w = paperWallet.recoverFromJson(wallet.toJson(), pwd);

      expect(wallet.toJson(), _w.toJson());
    });

    test('recover with wrong password', () {
      Wallet _w = paperWallet.recoverFromJson(wallet.toJson(), '12345');

      expect(_w, null);
    });
  });
}
