import 'dart:math';
import 'package:decimal/decimal.dart';
import 'utils.dart';

const SATOSHI_MAX = 21 * 1e14;

class Converter {
  static bool isShatoshi(int value) {
    return isUint(value, 53) && value <= SATOSHI_MAX;
  }

  static Decimal _btcInSatoshi = Decimal.parse(BigInt.from(1e8).toString());
  static Decimal _ethInWei = Decimal.parse(BigInt.from(1e18).toString());
  static Decimal toBtcCoinUnit(Decimal satoshi) {
    return satoshi / _btcInSatoshi;
  }

  static Decimal toBtcSmallestUnit(Decimal btc) {
    return btc * _btcInSatoshi;
  }

  static Decimal toEthCoinUnit(Decimal wei) {
    return wei / _ethInWei;
  }

  static Decimal toEthSmallestUnit(Decimal eth) {
    return eth * _ethInWei;
  }

  static BigInt toTokenSmallestUnit(Decimal value, int decimals) {
    return BigInt.parse(
        (value * Decimal.fromInt(pow(10, decimals))).toString());
  }
}
