import 'dart:typed_data';

import 'package:bs58check/bs58check.dart';
import 'package:sha3/sha3.dart';
// ignore: implementation_imports
import 'package:crypto/src/sha256.dart' as SHA256;

class Cryptor {
  static List<int> keccak256round(List<int> buffer, {int round = 2}) {
    List<int> result = buffer;
    if (round > 0) {
      var k = SHA3(256, KECCAK_PADDING, 256);
      k.update(result);
      var hash = k.digest();

      result = hash;

      return keccak256round(result, round: round - 1);
    }

    return result;
  }

  static String base58Encode(Uint8List payload) {
    final hash = _sha256(_sha256(payload));

    Uint8List combine = Uint8List.fromList(
        [payload, hash.sublist(0, 4)].expand((i) => i).toList(growable: false));
    return base58.encode(combine);
  }

  static Uint8List _sha256(Uint8List buffer) {
    return SHA256.sha256.newInstance().convert(buffer).bytes;
  }

  static Uint8List encodeBigInt(BigInt number) {
    var _byteMask = new BigInt.from(0xff);
    // Not handling negative numbers. Decide how you want to do that.
    int size = (number.bitLength + 7) >> 3;
    var result = new Uint8List(size);
    for (int i = 0; i < size; i++) {
      result[size - i - 1] = (number & _byteMask).toInt();
      number = number >> 8;
    }
    return result;
  }
}
