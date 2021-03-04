import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:convert/convert.dart';

import 'package:tidewallet3/helpers/cryptor.dart';

void main() {
  group('Cryptor function test', () {
    const testString =
        '{"id":1614845090026821,"jsonrpc":"2.0","result":{"approved":true,"chainId":1,"networkId":0,"accounts":["0x9c93C3Be6Abdc1DBf0f35F1e57a2CCfEA92A8e84"],"rpcUrl":"","peerId":"374f67ed-0c69-4e67-b197-c642d79a4b0d","peerMeta":{"description":"","url":"http://localhost:3000","icons":["http://localhost:3000/favicon.ico","http://localhost:3000/apple-touch-icon.png"],"name":"WalletConnect Test Wallet"}}}';
    final secret =
        'd490a36683a7c0ac42004fbdce89715edfb93f5e6616d17d00bab007233e0817';
    final iv = 'b1fdef93054a228d93c3f54fa95b223c';
    const result =
        'e41334cb8ebfb297829d4576a9e2731df0161ac359d19cd44a6907c11581b39c91be418f1930c83da553d3ae7b18b1c434310dff227f0720c12ed7dffb9fc05ce30b1a34ce96983c1ffeeb9b80e55a6017cbb24f16d3c67a0b1fd24d5f31188394c5e027f942cb682977743ba31772b9807c8c1c71a0f566753c911f77b8de02aab2d52cac7193a923b2d5717ee528e0fb662b5557f44ab24c766c8967d5ca6228595cdc33d4c4d064b74040000574d179b277de14d9d983c5887bb897b903588621dd7e7d713c79410a7c2d6d85f1befa6ed753f456cc5f201cd3fc1a407762682b930af559cca0f44a2762851ca5fa530836bc4a34c62f00e4f170f98fd6d8948f521fd83ba9af882ac326fd589cddc2089b6a04a4983d7fc5a78c385d640da4ed7b60b68a3e2d5e0cf12996f201fcff8e76e40394e8507e08dab2ab8fbb10afd8e067d588190122d42e54c9fa1807e64325c7ed11dd85c4ff8dc67a542fec09d8b025970625005208ca058ca80f105eb8c6e5550d6a6f56df1d5d9b2f497200f5a0a6fa8f1fc21dec876924434837';

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

    test('AES CBC encrypt', () {
      final str = Cryptor.aesEncrypt(testString, secret, iv);

      expect(str, result);
    });

    test('AES CBC decrypt', () {
      final secret =
          'd490a36683a7c0ac42004fbdce89715edfb93f5e6616d17d00bab007233e0817';
      final iv = 'b1fdef93054a228d93c3f54fa95b223c';

      final str = Cryptor.aesDecrypt(result, secret, iv);

      expect(str, testString);
    });
  });
}
