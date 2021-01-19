
import 'package:flutter_test/flutter_test.dart';
import 'package:tidewallet3/helpers/validator.dart';

void main() {
  group('Validator function test', () {
    Validator validator = Validator();
    
    test('validPassword correct', () {
      const String pwd = '12345Abc';
      const String walletName = 'new wallet';
      expect(validator.validPassword(pwd, walletName), [true, true, true, true]);
    });

    test('validPassword false rule 1', () {
      const String pwd = '123Abc';
      const String walletName = 'new wallet';
      expect(validator.validPassword(pwd, walletName), [false, true, true, true]);
    });

    test('validPassword false rule 2', () {
      const String pwd = 'aaaaaaaAbc';
      const String walletName = 'new wallet';
      expect(validator.validPassword(pwd, walletName), [true, false, true, true]);
    });

    test('validPassword false rule 3', () {
      const String pwd = '12345abc';
      const String walletName = 'new wallet';
      expect(validator.validPassword(pwd, walletName), [true, true, false, true]);
    });

    test('validPassword same name', () {
      const String pwd = '12345Abc';
      const String walletName = '12345Abc';
      expect(validator.validPassword(pwd, walletName), [true, true, true, false]);
    });
  });
}
