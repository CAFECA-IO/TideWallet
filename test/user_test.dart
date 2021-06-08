import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tidewallet3/helpers/cryptor.dart';
import 'package:tidewallet3/helpers/utils.dart';
import 'package:tidewallet3/helpers/rlp.dart' as rlp;
import 'package:convert/convert.dart';

void main() {
  String userIdentifier = 'test2ejknkjdniednwjq'; // utf
  String userId =
      randomHex(64); // hex 我忘記長度多少,辦公室有寫,或是問路飛,或是看我的code有沒有寫筆記,我沒認真找
  String userSecret = randomHex(64); // hex
  String installId = randomHex(64); // hex
  int timestamp = DateTime.now().millisecondsSinceEpoch;

  ///
  int nonce;
  Uint8List userIdentifierBuffer;
  Uint8List installIdBuffer;
  Uint8List nonceBuffer;
  group('user function test', () {
    test('getUserIdentifierBuffer', () {
      Uint8List _userIdentifierBuffer = ascii.encode(userIdentifier);
      userIdentifierBuffer = _userIdentifierBuffer;
      print("userIdentifierBuffer: $userIdentifierBuffer");
    });
    test('installIdBuffer', () {
      Uint8List _installIdBuffer = ascii.encode(installId);
      installIdBuffer = _installIdBuffer;
      print("installIdBuffer: $installIdBuffer");
    });
    test('getNonce', () {
      const int cafeca = 0xcafeca;
      int _nonce = cafeca;
      String getString(_nonce) {
        String result = hex
            .encode(Cryptor.keccak256round(
                (userIdentifierBuffer + rlp.toBuffer(_nonce)),
                round: 1))
            .substring(0, 3)
            .toLowerCase();
        return result;
      }

      while (getString(_nonce) != 'cfc') {
        _nonce++;
      }
      nonce = _nonce;
      print("nonce: $nonce");
      nonceBuffer = rlp.toBuffer(_nonce);
      //  expect(nonce, ur's nonce);
    });
    test('getPassword', () {
      List<int> pwseedBuffer = Cryptor.keccak256round(Cryptor.keccak256round(
              Cryptor.keccak256round(userIdentifierBuffer, round: 1) +
                  Cryptor.keccak256round(hex.decode(userId), round: 1)) +
          Cryptor.keccak256round(Cryptor.keccak256round(
                  rlp.toBuffer(
                      hex.encode(rlp.toBuffer(timestamp)).substring(3, 6)),
                  round: 1) +
              Cryptor.keccak256round(installIdBuffer, round: 1)));
      String password = hex.encode(Cryptor.keccak256round(pwseedBuffer));
      print("password: $password");
      //  expect(password, ur's password);
    });
    test('getExtend', () {
      Uint8List mainBuffer = Uint8List.fromList(
          (userIdentifierBuffer + nonceBuffer).sublist(0, 8));
      List<int> extendBuffer =
          Cryptor.keccak256round(nonceBuffer, round: 1).sublist(0, 4);
      List<int> seedBuffer = Cryptor.keccak256round(Cryptor.keccak256round(
              Cryptor.keccak256round(mainBuffer, round: 1) +
                  Cryptor.keccak256round(extendBuffer, round: 1)) +
          Cryptor.keccak256round(
              Cryptor.keccak256round(hex.decode(userId), round: 1) +
                  Cryptor.keccak256round(hex.decode(userSecret), round: 1)));
      String key = hex.encode(Cryptor.keccak256round(seedBuffer));
      String extend = hex.encode(extendBuffer);
      print("extend: $extend");
      //  expect(extend, ur's extend);
    });
  });
}
