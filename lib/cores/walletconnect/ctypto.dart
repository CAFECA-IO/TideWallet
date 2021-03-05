import '../../helpers/cryptor.dart';

class Crypto {
  static String encrypt(String message, String secret, String iv) {
    return Cryptor.aesEncrypt(message, secret, iv);
  }

  static String decrypto(String message, String secret, String iv) {
    return Cryptor.aesDecrypt(message, secret, iv);
  }

  static String hmac(String message, String hmacKey) {
    return Cryptor.hmacEncrypt(message, hmacKey);
  }
}