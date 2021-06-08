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
      '3fa33d09a46d4e31087a3b24dfe8dfb46750ce534641bd07fed54d2f23e97a0f'; //randomHex(64); // hex
  String userSecret =
      '971db42d2342f5e74a764e57e2d341103565f413a64f242d64b1f7024346a2e1'; //randomHex(64); // hex
  String installId =
      '11f6d3e524f367952cb838bf7ef24e0cfb5865d7b8a8fe5c699f748b2fada249'; //randomHex(64); // hex
  int timestamp = 1623129204183; //DateTime.now().millisecondsSinceEpoch;

  ///
  int nonce;
  Uint8List userIdentifierBuffer;
  Uint8List installIdBuffer;
  Uint8List nonceBuffer;
  group('user function test', () {
    test('getUserIdentifierBuffer', () {
      print(timestamp);
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
