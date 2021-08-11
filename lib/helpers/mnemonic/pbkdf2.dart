import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/digests/sha512.dart';
import 'package:pointycastle/key_derivators/api.dart' show Pbkdf2Parameters;
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';

class PBKDF2 {
  late final int blockLength;
  late final int iterationCount;
  late final int desiredKeyLength;
  late final String salt;

  late PBKDF2KeyDerivator _derivator;
  late Uint8List _salt;

  PBKDF2(
      {this.blockLength = 128,
      this.iterationCount = 2048,
      this.desiredKeyLength = 64,
      required this.salt}) {
    _salt = Uint8List.fromList(utf8.encode(salt));
    _derivator =
        new PBKDF2KeyDerivator(new HMac(new SHA512Digest(), blockLength))
          ..init(new Pbkdf2Parameters(_salt, iterationCount, desiredKeyLength));
  }

  Uint8List process(String mnemonic) {
    return _derivator.process(Uint8List.fromList(utf8.encode(mnemonic)));
  }
}
