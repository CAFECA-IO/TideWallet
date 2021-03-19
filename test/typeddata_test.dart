import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tidewallet3/cores/typeddata.dart';

void main() {
  final key = Uint8List.fromList(hex.decode(
      '588a77954fad4d0471e469b587357d73b1ed5d74d7adb98ee2ff99475e2e21ee'));
  final msg =
      '{"types":{"EIP712Domain":[{"name":"name","type":"string"},{"name":"version","type":"string"},{"name":"verifyingContract","type":"address"}],"RelayRequest":[{"name":"target","type":"address"},{"name":"encodedFunction","type":"bytes"},{"name":"gasData","type":"GasData"},{"name":"relayData","type":"RelayData"}],"GasData":[{"name":"gasLimit","type":"uint256"},{"name":"gasPrice","type":"uint256"},{"name":"pctRelayFee","type":"uint256"},{"name":"baseRelayFee","type":"uint256"}],"RelayData":[{"name":"senderAddress","type":"address"},{"name":"senderNonce","type":"uint256"},{"name":"relayWorker","type":"address"},{"name":"paymaster","type":"address"}]},"domain":{"name":"GSN Relayed Transaction","version":"1","chainId":42,"verifyingContract":"0x6453D37248Ab2C16eBd1A8f782a2CBC65860E60B"},"primaryType":"RelayRequest","message":{"target":"0x9cf40ef3d1622efe270fe6fe720585b4be4eeeff","encodedFunction":"0xa9059cbb0000000000000000000000002e0d94754b348d208d64d52d78bcd443afa9fa520000000000000000000000000000000000000000000000000000000000000007","gasData":{"gasLimit":"39507","gasPrice":"1700000000","pctRelayFee":"70","baseRelayFee":"0"},"relayData":{"senderAddress":"0x22d491bde2303f2f43325b2108d26f1eaba1e32b","senderNonce":"3","relayWorker":"0x3baee457ad824c94bd3953183d725847d023a2cf","paymaster":"0x957F270d45e9Ceca5c5af2b49f1b5dC1Abb0421c"}}}';
  final data = json.decode(msg);

  final types = {
    'EIP712Domain': [
      {'name': 'name', 'type': 'string'},
      {'name': 'version', 'type': 'string'},
      {'name': 'verifyingContract', 'type': 'address'}
    ],
    'RelayRequest': [
      {'name': 'target', 'type': 'address'},
      {'name': 'encodedFunction', 'type': 'bytes'},
      {'name': 'gasData', 'type': 'GasData'},
      {'name': 'relayData', 'type': 'RelayData'}
    ],
    'GasData': [
      {'name': 'gasLimit', 'type': 'uint256'},
      {'name': 'gasPrice', 'type': 'uint256'},
      {'name': 'pctRelayFee', 'type': 'uint256'},
      {'name': 'baseRelayFee', 'type': 'uint256'}
    ],
    'RelayData': [
      {'name': 'senderAddress', 'type': 'address'},
      {'name': 'senderNonce', 'type': 'uint256'},
      {'name': 'relayWorker', 'type': 'address'},
      {'name': 'paymaster', 'type': 'address'}
    ]
  };

  group('V4', () {
    test('encodeData domain', () {
      final primaryType = 'EIP712Domain';
      final data = {
        'name': 'GSN Relayed Transaction',
        'version': '1',
        'chainId': 42,
        'verifyingContract': '0x6453D37248Ab2C16eBd1A8f782a2CBC65860E60B'
      };

      final result = TypedData.encodeData(primaryType, data, types, true);
      expect(result,
          '91ab3d17e3a50a9d89e63fd30b92be7f5336b03b287bb946787a83a9d62a27669647bda542dcf6621898cb1d03b22adb04c620d77e0bc6e67edb695f5f57777ec89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc60000000000000000000000006453d37248ab2c16ebd1a8f782a2cbc65860e60b');
    });

    test('encodeData gasData', () {
      final primaryType = 'GasData';
      final data = {
        'gasLimit': '39507',
        'gasPrice': '1700000000',
        'pctRelayFee': '70',
        'baseRelayFee': '0'
      };

      final result = TypedData.encodeData(primaryType, data, types, true);

      expect(result,
          'd4d124fcf2dbb8c7b3fdba71ca7d085e2ef84141e4e237abc2d7e44f336e8dee0000000000000000000000000000000000000000000000000000000000009a53000000000000000000000000000000000000000000000000000000006553f10000000000000000000000000000000000000000000000000000000000000000460000000000000000000000000000000000000000000000000000000000000000');
    });

    test('encodeData RelayRequest', () {
      final primaryType = 'RelayRequest';
      final data = {
        'target': '0x9cf40ef3d1622efe270fe6fe720585b4be4eeeff',
        'encodedFunction':
            '0xa9059cbb0000000000000000000000002e0d94754b348d208d64d52d78bcd443afa9fa520000000000000000000000000000000000000000000000000000000000000007',
        'gasData': {
          'gasLimit': '39507',
          'gasPrice': '1700000000',
          'pctRelayFee': '70',
          'baseRelayFee': '0'
        },
        'relayData': {
          'senderAddress': '0x22d491bde2303f2f43325b2108d26f1eaba1e32b',
          'senderNonce': '3',
          'relayWorker': '0x3baee457ad824c94bd3953183d725847d023a2cf',
          'paymaster': '0x957F270d45e9Ceca5c5af2b49f1b5dC1Abb0421c'
        }
      };

      final result = TypedData.encodeData(primaryType, data, types, true);
      expect(result,
          '2ff8cad9fc52c931beef9178a726d1ab6280a9c2b6a6396450a181819cf1e5400000000000000000000000009cf40ef3d1622efe270fe6fe720585b4be4eeeffa9485354dd9d340e02789cfc540c6c4a2ff5511beb414b64634a5e11c6a7168cff9bf07e24e6ff0943eadc198a43500e4016d41517b01c92d4b2217909610371b070fcfff74c07b7820d93159a2fd5cb8e2fdf060ee7b42e79f1b4414bccccc1');
    });

    test('signTypedData', () {
      final result = TypedData.signTypedData_v4(key, data);

      expect(result,
          '0x2e8640fd20a6468f0ba9db18dcc1ba50e8e6e8fc19e9f274acd05ef43b01ada44097bf16079622efb440ef222edd28c3d052bcedcc40e659df4f17e6a24c465b1b');
    });
  });
}
