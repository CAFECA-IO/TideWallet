import 'package:flutter_test/flutter_test.dart';
import 'package:convert/convert.dart';

import 'package:tidewallet3/helpers/cryptor.dart';

void main() {
  group('Cryptor function test', () {
    test('Cryptor.keccak256round Correct', () {
      const t = '3cd24b9fcf2bebf73a89e265689706a0e1de1f4e';

      const expectRound1 =
          'f6efffe3ae395fa2a9e9a6b23702bac369e5eb755927faba2b368543e1279a2e';
      var hash = Cryptor.keccak256round(hex.decode(t), round: 1);

      expect(hex.encode(hash), expectRound1);

      hash = Cryptor.keccak256round(hex.decode(t));
      const expectRound2 =
          '5dc9bffab110413a2ea64cda0e34133d4106553798c38f1cd9161e10094fc5a8';

      expect(hex.encode(hash), expectRound2);

      hash = Cryptor.keccak256round(hex.decode(t), round: 3);
      const expectRound3 =
          'daeeefa2eec3c3114642d45c1f6473ece159cfccc10678acebf5d406ff9cfff1';

      expect(hex.encode(hash), expectRound3);
    });
  });
}
