import 'package:sha3/sha3.dart';

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
}
