import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/export.dart';

import 'package:bs58check/bs58check.dart';
import 'package:sha3/sha3.dart';
// import 'package:bird_cryptography/bird_cryptography.dart' as bird;
// ignore: implementation_imports
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;

// import 'logger.dart';

class Cryptor {
  static Uint8List keccak256round(List<int> buffer, {int round = 2}) {
    List<int> result = buffer;
    if (round > 0) {
      SHA3 k = SHA3(256, KECCAK_PADDING, 256);
      k.update(result);
      List<int> hash = k.digest();

      result = hash;

      return keccak256round(result, round: round - 1);
    }

    return Uint8List.fromList(result);
  }

  String keccak256Hash(String data) {
    return hex.encode(keccak256round(hex.decode(data), round: 1));
  }

  // static Uint8List ripemd160Legacy(List<int> data) {
  //   final bird.CryptographyHashes dartHashes = bird.CryptographyHashes.dart;
  //   final bird.CryptographyHash ripemd160 = dartHashes.ripemd160();
  //   List<int> ripemd160Data = ripemd160.digestRaw(Uint8List.fromList(data));
  //   return ripemd160Data;
  // }

  static Uint8List ripemd160(List<int> data) {
    final RIPEMD160Digest ripemd160 = RIPEMD160Digest();
    List<int> ripemd160Data = ripemd160.process(Uint8List.fromList(data));
    return Uint8List.fromList(ripemd160Data);
  }

  static Uint8List hash160(List<int> data) {
    return ripemd160(sha256round(data, round: 1));
  }

  static Uint8List sha256round(List<int> buffer, {int round = 2}) {
    List<int> result = buffer;
    if (round > 0) {
      List<int> hash = crypto.sha256.convert(buffer).bytes;

      result = hash;

      return sha256round(result, round: round - 1);
    }

    return Uint8List.fromList(result);
  }

  static String base58Encode(Uint8List payload) {
    final hash = sha256round(payload);

    Uint8List combine = Uint8List.fromList(
        [payload, hash.sublist(0, 4)].expand((i) => i).toList(growable: false));
    return base58.encode(combine);
  }

  static String aesEncrypt(String message, String secret, String iv) {
    final key = encrypt.Key.fromBase16(secret);

    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    final encrypted = encrypter.encrypt(message, iv: encrypt.IV.fromBase16(iv));

    return encrypted.base16;
  }

  static String aesDecrypt(String message, String secret, String iv) {
    String decrypted;
    final key = encrypt.Key.fromBase16(secret);
    final _iv = encrypt.IV.fromBase16(iv);
    try {
      final encrypter =
          encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      decrypted =
          encrypter.decrypt(encrypt.Encrypted.fromBase16(message), iv: _iv);
    } catch (_) {
      final encrypter = encrypt.Encrypter(
          encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: null));
      decrypted =
          encrypter.decrypt(encrypt.Encrypted.fromBase16(message), iv: _iv);
    }

    return decrypted;
  }

  static String genIV({int bytes: 16}) {
    final iv = encrypt.IV.fromSecureRandom(bytes);
    return hex.encode(iv.bytes);
  }

  /// message, hmacKey must be Base16 string, looks like: 'b1fdef93054a228d93c3f54fa95b223c'
  static String hmacEncrypt(String message, String hmacKey) {
    var key = hex.decode(hmacKey);
    var bytes = hex.decode(message);

    var hmacSha256 = crypto.Hmac(crypto.sha256, key);
    var digest = hmacSha256.convert(bytes);

    return digest.toString();
  }
}
