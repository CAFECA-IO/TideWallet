import 'package:crypto/crypto.dart';

class Cryptor {
  static List<int> sha256round(List<int> buffer, { int round = 2 }) {
    List<int>  result = buffer;
    if (round > 0) {
      result = sha256.newInstance().convert(result).bytes;

      return sha256round(result, round: round - 1);
    }

    return result;
  }
}