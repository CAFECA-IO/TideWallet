import 'dart:typed_data';
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:convert/convert.dart';

import './utils.dart';
import './bech32.dart';
import './segwit.dart';
import './logger.dart';

const int OP_0 = 0x00;
const int OP_PUSHDATA1 = 0x4c;
const int OP_PUSHDATA2 = 0x4d;
const int OP_PUSHDATA4 = 0x4e;
const int OP_1NEGATE = 0x4f;
const int OP_1 = 0x51;
const int OP_16 = 0x60;
const int OP_DUP = 0x76;
const int OP_EQUAL = 0x87;
const int OP_EQUALVERIFY = 0x88;
const int OP_HASH160 = 0xa9;
const int OP_CHECKSIG = 0xac;
const int OP_CODESEPARATOR = 0xab;

Uint8List compressedPubKey(List<int> uncompressedPubKey) {
  //**https://bitcoin.stackexchange.com/questions/69315/how-are-compressed-pubkeys-generated
  //https://bitcointalk.org/index.php?topic=644919.0
  if (uncompressedPubKey.length % 2 == 1) {
    uncompressedPubKey =
        uncompressedPubKey.sublist(1, uncompressedPubKey.length);
  }
  List<int> x = uncompressedPubKey.sublist(0, 32);
  List<int> y = uncompressedPubKey.sublist(32, 64);
  BigInt p = BigInt.parse(
      'fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f',
      radix: 16);
  BigInt xInt = BigInt.parse(hex.encode(x), radix: 16);
  BigInt yInt = BigInt.parse(hex.encode(y), radix: 16);
  BigInt check = (xInt.pow(3) + BigInt.from(7) - yInt.pow(2)) % p;

  if (check == BigInt.zero) {
    List<int> prefix =
        BigInt.parse(hex.encode(y), radix: 16).isEven ? [0x02] : [0x03];
    return Uint8List.fromList(prefix + x);
  }
}

Uint8List toPubKeyHash(List<int> pubKey) {
  List<int> pubKeyHash =
      ripemd160(sha256(pubKey)); //TODO pubKey is Compressed or UnCompressed
  return pubKeyHash;
}

Uint8List pubKeyHashToP2pkhScript(List<int> pubKeyHash) {
  // Pubkey Hash to P2PKH Script
  List<int> data = [];
  data.add(OP_DUP); //0x76;
  data.add(OP_HASH160); // 0xa9;
  data.add(pubKeyHash.length);
  data.addAll(pubKeyHash);
  data.add(OP_EQUALVERIFY); //0x88;
  data.add(OP_CHECKSIG); // 0xac；
  return Uint8List.fromList(data);
}

Uint8List pubKeyHashToP2shScript(List<int> pubKeyHash) {
  // Pubkey Hash to P2PKH Script
  List<int> data = [];
  data.add(OP_HASH160);
  data.add(pubKeyHash.length);
  data.addAll(pubKeyHash);
  data.add(OP_EQUAL);
  return Uint8List.fromList(data);
}

Uint8List pubkeyToP2PKScript(List<int> pubKey) {
  List<int> publicKey = pubKey.length > 33 ? compressedPubKey(pubKey) : pubKey;
  List<int> data = [];
  data.add(publicKey.length);
  data.addAll(publicKey);
  data.add(OP_CHECKSIG);
  return Uint8List.fromList(data);
  ;
}

Uint8List pubkeyToBIP49RedeemScript(List<int> pubKey) {
  List<int> rs = [0x00, 0x14];
  rs.addAll(
      ripemd160(sha256(pubKey))); //TODO pubKey is Compressed or UnCompressed
  return Uint8List.fromList(rs);
}

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

List<int> extractScriptPubkeyFromSegwitAddress(String address) {
  // Extract Script Pubkey from SegWit Address
  Segwit _address = segwit.decode(address);
  List<int> scriptPubKey = hex.decode(_address.scriptPubKey);
  // PBLog.debug('scriptPubKey: $scriptPubKey');
  return scriptPubKey;
}

bool isP2pkhAddress(String address, int p2pkhAddressPrefix) {
  Log.debug('p2pkhAddressPrefix: $p2pkhAddressPrefix');
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
