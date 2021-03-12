import 'dart:math';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:decimal/decimal.dart';

String randomHex(int length) {
  const array = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 'a', 'b', 'c', 'd', 'e', 'f'];
  String hex = ''; //      var subPSKID = [];
  for (int index = 0; index < length; index++) {
    hex += array[Random().nextInt(16)]
        .toString(); //        subPSKID.add(array[i]);
  }
  return hex;
}

bool isHexString(String value, {int length = 0}) {
  // checkNotNull(value);
  if (!RegExp('^0x[0-9A-Fa-f]*\$').hasMatch(value)) {
    return false;
  }
  if (length > 0 && value.length != 2 + 2 * length) {
    return false;
  }
  return true;
}

/// Pads a [String] to have an even length
String padToEven(String value) {
  // checkNotNull(value);
  String a = value;
  if (a.length % 2 == 1) {
    a = "0$a";
  }
  return a;
}

bool isHexPrefixed(String str) {
  // checkNotNull(str);
  return str.isEmpty
      ? false
      : str.substring(0, 2) == '0x' || str.substring(0, 2) == '0X';
}

String stripHexPrefix(String str) {
  // checkNotNull(str);
  return isHexPrefixed(str) ? str.substring(2) : str;
}

/// Converts a [int] into a hex [String]
String intToHex(int i) {
  // checkNotNull(i);
  return "0x${i.toRadixString(16)}";
}

/// Converts an [int] to a [Uint8List]
Uint8List intToBuffer(int i) {
  // checkNotNull(i);
  return Uint8List.fromList(hex.decode(padToEven(intToHex(i).substring(2))));
}

/// Encode a BigInt into bytes using big-endian encoding.
Uint8List encodeBigInt(BigInt number) {
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

/// Decode a BigInt from bytes in big-endian encoding.
BigInt decodeBigInt(List<int> bytes) {
  BigInt result = new BigInt.from(0);
  for (int i = 0; i < bytes.length; i++) {
    result += new BigInt.from(bytes[bytes.length - i - 1]) << (8 * i);
  }
  return result;
}

BigInt fromBuffer(Uint8List d) {
  return decodeBigInt(d);
}

Uint8List toDER(Uint8List x) {
  final ZERO = Uint8List.fromList([0]);
  var i = 0;
  while (x[i] == 0) ++i;
  if (i == x.length) return ZERO;
  x = x.sublist(i);
  List<int> combine = List.from(ZERO);
  combine.addAll(x);
  if (x[0] & 0x80 != 0) return Uint8List.fromList(combine);
  return x;
}

Uint8List bip66encode(r, s) {
  var lenR = r.length;
  var lenS = s.length;
  if (lenR == 0) throw new ArgumentError('R length is zero');
  if (lenS == 0) throw new ArgumentError('S length is zero');
  if (lenR > 33) throw new ArgumentError('R length is too long');
  if (lenS > 33) throw new ArgumentError('S length is too long');
  if (r[0] & 0x80 != 0) throw new ArgumentError('R value is negative');
  if (s[0] & 0x80 != 0) throw new ArgumentError('S value is negative');
  if (lenR > 1 && (r[0] == 0x00) && r[1] & 0x80 == 0)
    throw new ArgumentError('R value excessively padded');
  if (lenS > 1 && (s[0] == 0x00) && s[1] & 0x80 == 0)
    throw new ArgumentError('S value excessively padded');

  var signature = new Uint8List(6 + lenR + lenS);

  // 0x30 [total-length] 0x02 [R-length] [R] 0x02 [S-length] [S]
  signature[0] = 0x30;
  signature[1] = signature.length - 2;
  signature[2] = 0x02;
  signature[3] = r.length;
  signature.setRange(4, 4 + lenR, r);
  signature[4 + lenR] = 0x02;
  signature[5 + lenR] = s.length;
  signature.setRange(6 + lenR, 6 + lenR + lenS, s);
  return signature;
}

bool isUint(int value, int bit) {
  return (value >= 0 && value <= pow(2, bit) - 1);
}

bool isHash160bit(Uint8List value) {
  return value.length == 20;
}

bool isHash256bit(Uint8List value) {
  return value.length == 32;
}


Decimal hexStringToDecimal(String str) =>
      Decimal.fromInt(int.tryParse(str.replaceAll('0x', ''), radix: 16));