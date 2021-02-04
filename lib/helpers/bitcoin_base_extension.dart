import 'dart:typed_data';
import 'package:bs58check/bs58check.dart' as bs58check;

import './bech32.dart';
import './segwit.dart';
import './logger.dart';

Uint8List decodeAddress(String address) {
  if (address.contains(':')) {
    address = address.split(':')[1];
  }
  Uint8List decodedData;
  try {
    decodedData = bs58check.decode(address);
  } catch (e) {
    return Uint8List(0);
  }
  return decodedData;
}

bool isP2pkhAddress(String address, int p2pkhAddressPrefix) {
  Uint8List decodedData = decodeAddress(address);
  if (decodedData.length != 21) return false;
  bool isP2pkhAddress = decodedData.first == p2pkhAddressPrefix;

  return isP2pkhAddress;
}

bool isP2shAddress(String address, int p2shAddressPrefix) {
  Uint8List decodedData = decodeAddress(address);
  if (decodedData.length != 21) return false;
  bool isP2pkhAddress = decodedData.first == p2shAddressPrefix;

  return isP2pkhAddress;
}

bool isSegWitAddress(String address, String bech32HRP, String bech32Separator) {
  if (address.contains(':')) {
    address = address.split(':')[1];
  }
  String hrp = "";
  if (address.startsWith('$bech32HRP$bech32Separator')) {
    hrp = bech32HRP;
  } else
    return false;
  Bech32Codec codec = Bech32Codec();
  try {
    Bech32 bech32 = codec.decode(
      address,
      address.length,
    );
    if (bech32.hrp != hrp) return false;
    int version = bech32.data[0];
    List<int> program = convertBits(bech32.data.sublist(1), 5, 8, false);
    if (version == 0 && program.length == 20) {
      // P2WPKH
      return true;
    }
    if (version == 0 && program.length == 32) {
      // P2WSH
      return true;
    }
  } on Exception catch (e) {
    Log.debug('$e');
    return false;
  }
  return false;
}
