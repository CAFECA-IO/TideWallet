import 'dart:typed_data';

import 'package:bs58check/bs58check.dart';
import 'package:sha3/sha3.dart';
import 'package:bird_cryptography/bird_cryptography.dart' as bird;
import 'package:crypto/src/sha256.dart' as SHA256;
import 'package:convert/convert.dart';

import 'logger.dart';

class Cryptor {
  static List<int> keccak256round(List<int> buffer, {int round = 2}) {
    List<int> result = buffer;
    Log.debug('keccak256round buffer: $buffer');
    if (round > 0) {
      SHA3 k = SHA3(256, KECCAK_PADDING, 256);
      k.update(result);
      List<int> hash = k.digest();

      result = hash;

      return keccak256round(result, round: round - 1);
    }

    Log.debug('keccak256round result2: $result');
    return result;
  }

  String keccak256Hash(String data) {
    return hex.encode(keccak256round(hex.decode(data), round: 1));
  }

  static List<int> ripemd160(List<int> data) {
    final bird.CryptographyHashes dartHashes = bird.CryptographyHashes.dart;
    final bird.CryptographyHash ripemd160 = dartHashes.ripemd160();
    List<int> ripemd160Data = ripemd160.digestRaw(Uint8List.fromList(data));
    return ripemd160Data;
  }

  static List<int> hash160(List<int> data) {
    return ripemd160(sha256round(data, round: 1));
  }

  static List<int> sha256round(List<int> buffer, {int round = 2}) {
    List<int> result = buffer;
    if (round > 0) {
      List<int> hash = SHA256.sha256.newInstance().convert(buffer).bytes;

      result = hash;

      return sha256round(result, round: round - 1);
    }

    return result;
  }

  static String base58Encode(Uint8List payload) {
    final hash = sha256round(payload);

    Uint8List combine = Uint8List.fromList(
        [payload, hash.sublist(0, 4)].expand((i) => i).toList(growable: false));
    return base58.encode(combine);
  }
}
