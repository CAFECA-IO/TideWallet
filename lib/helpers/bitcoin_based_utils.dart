import 'dart:typed_data';
import 'package:meta/meta.dart';
import 'package:fixnum/fixnum.dart';
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:convert/convert.dart';
import 'package:bip32/src/utils/ecurve.dart' show isPoint;
import '../constants/op.dart';
import 'exceptions.dart';
import 'script.dart' as bscript;

import 'cryptor.dart';
import 'bech32.dart';
import 'segwit.dart';
import 'logger.dart';

// const int OP_0 = 0x00;
// const int OP_PUSHDATA1 = 0x4c;
// const int OP_PUSHDATA2 = 0x4d;
// const int OP_PUSHDATA4 = 0x4e;
// const int OP_1NEGATE = 0x4f;
// const int OP_1 = 0x51;
// const int OP_16 = 0x60;
// const int OP_DUP = 0x76;
// const int OP_EQUAL = 0x87;
// const int OP_EQUALVERIFY = 0x88;
// const int OP_HASH160 = 0xa9;
// const int OP_CHECKSIG = 0xac;
// const int OP_CODESEPARATOR = 0xab;

/// Works with both legacy and cashAddr formats of the address
///
/// There is no reason to instanciate this class. All constants, functions, and methods are static.
/// It is assumed that all necessary data to work with addresses are kept in the instance of [ECPair] or [Transaction]
class Address {
  static const formatCashAddr = 0;
  static const formatLegacy = 1;

  static const _CHARSET = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';
  static const _CHARSET_INVERSE_INDEX = {
    'q': 0,
    'p': 1,
    'z': 2,
    'r': 3,
    'y': 4,
    '9': 5,
    'x': 6,
    '8': 7,
    'g': 8,
    'f': 9,
    '2': 10,
    't': 11,
    'v': 12,
    'd': 13,
    'w': 14,
    '0': 15,
    's': 16,
    '3': 17,
    'j': 18,
    'n': 19,
    '5': 20,
    '4': 21,
    'k': 22,
    'h': 23,
    'c': 24,
    'e': 25,
    '6': 26,
    'm': 27,
    'u': 28,
    'a': 29,
    '7': 30,
    'l': 31,
  };

  /// Converts legacy address to cash address
  static String toCashAddress(String legacyAddress,
      [bool includePrefix = true]) {
    final decoded = Address._decodeLegacyAddress(legacyAddress);
    String prefix = "";
    if (includePrefix) {
      switch (decoded["version"]) {
        case Network.bchPublic:
          prefix = "bitcoincash";
          break;
        case Network.bchTestnetPublic:
          prefix = "bchtest";
          break;
        default:
          throw FormatException("Unsupported address format: $legacyAddress");
      }
    }

    final cashAddress = Address._encode(prefix, "P2PKH", decoded["hash"]);
    return cashAddress;
  }

  /// Converts cashAddr format to legacy address
  static String toLegacyAddress(String cashAddress) {
    final decoded = _decodeCashAddress(cashAddress);
    final testnet = decoded['prefix'] == "bchtest";

    final version = !testnet ? Network.bchPublic : Network.bchTestnetPublic;
    return toBase58Check(decoded["hash"], version);
  }

  /// Detects type of the address and returns [formatCashAddr] or [formatLegacy]
  static int detectFormat(String address) {
    // decode the address to determine the format
    final decoded = _decode(address);
    // return the format
    return decoded["format"];
  }

  /// Generates legacy address format
  static String toBase58Check(Uint8List hash, int version) {
    Uint8List payload = Uint8List(21);
    payload[0] = version;
    payload.setRange(1, payload.length, hash);
    return bs58check.encode(payload);
  }

  /*
  static Uint8List _toOutputScript(address, network) {
    return bscript.compile([
      Opcodes.OP_DUP,
      Opcodes.OP_HASH160,
      address,
      Opcodes.OP_EQUALVERIFY,
      Opcodes.OP_CHECKSIG
    ]);
  }*/

  /// Encodes a hash from a given type into a Bitcoin Cash address with the given prefix.
  /// [prefix] - Network prefix. E.g.: 'bitcoincash'.
  /// [type] is currently unused - the library works only with _P2PKH_
  /// [hash] is the address hash, which can be decode either using [_decodeCashAddress()] or [_decodeLegacyAddress()]
  static _encode(String prefix, String type, Uint8List hash) {
    final prefixData = _prefixToUint5List(prefix) + Uint8List(1);
    final versionByte = _getHashSizeBits(hash);
    final payloadData =
        _convertBits(Uint8List.fromList([versionByte] + hash), 8, 5);
    final checksumData = prefixData + payloadData + Uint8List(8);
    final payload = payloadData + _checksumToUint5Array(_polymod(checksumData));
    return "$prefix:" + _base32Encode(payload);
  }

  /// Derives an array from the given prefix to be used in the computation of the address' checksum.
  static Uint8List _prefixToUint5List(String prefix) {
    Uint8List result = Uint8List(prefix.length);
    for (int i = 0; i < prefix.length; i++) {
      result[i] = prefix.codeUnitAt(i) & 31;
    }
    return result;
  }

  /// Returns the bit representation of the length in bits of the given hash within the version byte.
  static int _getHashSizeBits(hash) {
    switch (hash.length * 8) {
      case 160:
        return 0;
      case 192:
        return 1;
      case 224:
        return 2;
      case 256:
        return 3;
      case 320:
        return 4;
      case 384:
        return 5;
      case 448:
        return 6;
      case 512:
        return 7;
      default:
        throw Exception('Invalid hash size: ' + hash.length + '.');
    }
  }

  /// Retrieves the the length in bits of the encoded hash from its bit representation within the version byte.
  static int _getHashSize(versionByte) {
    switch (versionByte & 7) {
      case 0:
        return 160;
      case 1:
        return 192;
      case 2:
        return 224;
      case 3:
        return 256;
      case 4:
        return 320;
      case 5:
        return 384;
      case 6:
        return 448;
      case 7:
        return 512;
    }

    return -1;
  }

  /// Decodes the given address into:
  /// * (for cashAddr): constituting prefix (e.g. _bitcoincash_)
  /// * (for legacy): version
  /// * hash
  /// * format
  static Map<String, dynamic> _decode(String address) {
    try {
      return _decodeLegacyAddress(address);
    } catch (e) {}

    try {
      return _decodeCashAddress(address);
    } catch (e) {}

    throw FormatException("Invalid address format : $address");
  }

  /// Decodes legacy address into a [Map] with version, hash and format
  static Map<String, dynamic> _decodeLegacyAddress(String address) {
    Uint8List buffer = bs58check.decode(address);

    return <String, dynamic>{
      "version": buffer.first,
      "hash": buffer.sublist(1),
      "format": formatLegacy,
    };
  }

  /// Decodes the given address into its constituting prefix, type and hash
  ///
  /// if [address] doesn't contain prefix (e.g. bitcoincash:), it will try and validate different prefixes and return
  /// the correct one
  static Map<String, dynamic> _decodeCashAddress(String address) {
    if (!_hasSingleCase(address)) {
      throw FormatException("Address has both lower and upper case: $address");
    }

    // split the address with : separator to find out it if contains prefix
    final pieces = address.toLowerCase().split(":");

    // placeholder for different prefixes to be tested later
    List<String> prefixes;

    // check if the address contained : separator by looking at number of splitted pieces
    if (pieces.length == 2) {
      // if it contained the separator, use the first piece as a single prefix
      prefixes = <String>[pieces.first];
      address = pieces.last;
    } else if (pieces.length == 1) {
      // if it came without separator, try all three possible formats
      prefixes = <String>["bitcoincash", "bchtest", "bchreg"];
    } else {
      // if it came with more than one separator, throw a format exception
      throw FormatException("Invalid Address Format: $address");
    }

    String exception;
    // try to decode the address with either one or all three possible prefixes
    for (int i = 0; i < prefixes.length; i++) {
      final payload = _base32Decode(address);

      if (!_validChecksum(prefixes[i], payload)) {
        exception = "Invalid checksum: $address";
        continue;
      }

      final payloadData =
          _fromUint5Array(payload.sublist(0, payload.length - 8));
      final hash = payloadData.sublist(1);

      if (_getHashSize(payloadData[0]) != hash.length * 8) {
        exception = "Invalid hash size: $address";
        continue;
      }

      // If the loop got all the way here, it means validations went through and the address was decoded.
      // Return the decoded data
      return <String, dynamic>{
        "prefix": prefixes[i],
        "hash": hash,
        "format": formatCashAddr
      };
    }

    // if the loop went through all possible formats and didn't return data from the function, it means there were
    // validation issues. Throw a format exception
    throw FormatException(exception);
  }

  /// Converts a list of 5-bit integers back into an array of 8-bit integers, removing extra zeroes left from padding
  /// if necessary.
  static Uint8List _fromUint5Array(Uint8List data) {
    return _convertBits(data, 5, 8, true);
  }

  /// Returns a list representation of the given checksum to be encoded within the address' payload.
  static Uint8List _checksumToUint5Array(int checksum) {
    Uint8List result = Uint8List(8);
    for (int i = 0; i < 8; i++) {
      result[7 - i] = checksum & 31;
      checksum = checksum >> 5;
    }

    return result;
  }

  /// Converts a list of integers made up of 'from' bits into an  array of integers made up of 'to' bits.
  /// The output array is zero-padded if necessary, unless strict mode is true.
  static Uint8List _convertBits(List data, int from, int to,
      [bool strictMode = false]) {
    final length = strictMode
        ? (data.length * from / to).floor()
        : (data.length * from / to).ceil();
    int mask = (1 << to) - 1;
    var result = Uint8List(length);
    int index = 0;
    Int32 accumulator = Int32(0);
    int bits = 0;
    for (int i = 0; i < data.length; ++i) {
      var value = data[i];
      accumulator = (accumulator << from) | value;
      bits += from;
      while (bits >= to) {
        bits -= to;
        result[index] = ((accumulator >> bits) & mask).toInt();
        ++index;
      }
    }

    if (!strictMode) {
      if (bits > 0) {
        result[index] = ((accumulator << (to - bits)) & mask).toInt();
        ++index;
      }
    } else {
      if (bits < from && ((accumulator << (to - bits)) & mask).toInt() != 0) {
        throw FormatException(
            "Input cannot be converted to $to bits without padding, but strict mode was used.");
      }
    }
    return result;
  }

  /// Computes a checksum from the given input data as specified for the CashAddr format:
  // https://github.com/Bitcoin-UAHF/spec/blob/master/cashaddr.md.
  static int _polymod(List data) {
    const GENERATOR = [
      0x98f2bc8e61,
      0x79b76d99e2,
      0xf33e5fb3c4,
      0xae2eabe2a8,
      0x1e4f43e470
    ];

    int checksum = 1;

    for (int i = 0; i < data.length; ++i) {
      final value = data[i];
      final topBits = checksum >> 35;
      checksum = ((checksum & 0x07ffffffff) << 5) ^ value;

      for (int j = 0; j < GENERATOR.length; ++j) {
        if ((topBits >> j) & 1 == 1) {
          checksum = checksum ^ GENERATOR[j];
        }
      }
    }

    return checksum ^ 1;
  }

  static Uint8List _base32Decode(String string) {
    final data = Uint8List(string.length);
    for (int i = 0; i < string.length; i++) {
      final value = string[i];
      if (!_CHARSET_INVERSE_INDEX.containsKey(value))
        throw FormatException("Invalid character '$value'");
      data[i] = _CHARSET_INVERSE_INDEX[string[i]];
    }

    return data;
  }

  static _base32Encode(List data) {
    String base32 = '';
    for (int i = 0; i < data.length; ++i) {
      var value = data[i];
      //validate(0 <= value && value < 32, 'Invalid value: ' + value + '.');
      base32 += _CHARSET[value];
    }
    return base32;
  }

  static bool _hasSingleCase(String address) {
    return address == address.toLowerCase() || address == address.toUpperCase();
  }

  /// Verify that the payload has not been corrupted by checking that the checksum is valid.
  static _validChecksum(String prefix, Uint8List payload) {
    final prefixData = _prefixToUint5List(prefix) + Uint8List(1);
    final checksumData = prefixData + payload;
    return _polymod(checksumData) == 0;
  }
}

class Network {
  static const bchPrivate = 0x80;
  static const bchTestnetPrivate = 0xef;

  static const bchPublic = 0x00;
  static const bchTestnetPublic = 0x6f;

  final int bip32Private;
  final int bip32Public;
  final bool testnet;
  final int pubKeyHash;
  final int private;
  final int public;

  Network(this.bip32Private, this.bip32Public, this.testnet, this.pubKeyHash,
      this.private, this.public);

  factory Network.bitcoinCash() =>
      Network(0x0488ade4, 0x0488b21e, false, 0x00, bchPrivate, bchPublic);
  factory Network.bitcoinCashTest() => Network(
      0x04358394, 0x043587cf, true, 0x6f, bchTestnetPrivate, bchTestnetPublic);

  String get prefix => this.testnet ? "bchtest" : "bitcoincash";
}

class NetworkType {
  String messagePrefix;
  String bech32;
  Bip32Type bip32;
  int pubKeyHash;
  int scriptHash;
  int wif;

  NetworkType(
      {@required this.messagePrefix,
      this.bech32,
      @required this.bip32,
      @required this.pubKeyHash,
      @required this.scriptHash,
      @required this.wif});

  @override
  String toString() {
    return 'NetworkType{messagePrefix: $messagePrefix, bech32: $bech32, bip32: ${bip32.toString()}, pubKeyHash: $pubKeyHash, scriptHash: $scriptHash, wif: $wif}';
  }
}

class Bip32Type {
  int public;
  int private;

  Bip32Type({@required this.public, @required this.private});

  @override
  String toString() {
    return 'Bip32Type{public: $public, private: $private}';
  }
}

class PaymentData {
  String address;
  Uint8List hash;
  Uint8List output;
  Uint8List signature;
  Uint8List pubkey;
  Uint8List input;
  List<Uint8List> witness;

  PaymentData(
      {this.address,
      this.hash,
      this.output,
      this.pubkey,
      this.input,
      this.signature,
      this.witness});

  @override
  String toString() {
    return 'PaymentData{address: $address, hash: $hash, output: $output, signature: $signature, pubkey: $pubkey, input: $input, witness: $witness}';
  }
}

class P2WPKH {
  final EMPTY_SCRIPT = Uint8List.fromList([]);

  PaymentData data;
  NetworkType network;
  P2WPKH({@required data, network}) {
    this.network = network ?? bitcoin;
    this.data = data;
    _init();
  }

  _init() {
    if (data.address == null &&
        data.hash == null &&
        data.output == null &&
        data.pubkey == null &&
        data.witness == null) throw new ArgumentError('Not enough data');

    if (data.address != null) {
      _getDataFromAddress(data.address);
    }

    if (data.hash != null) {
      _getDataFromHash();
    }

    if (data.output != null) {
      if (data.output.length != 22 ||
          data.output[0] != OPS['OP_0'] ||
          data.output[1] != 20) // 0x14
        throw new ArgumentError('Output is invalid');
      if (data.hash == null) {
        data.hash = data.output.sublist(2);
      }
      _getDataFromHash();
    }

    if (data.pubkey != null) {
      data.hash = Cryptor.hash160(data.pubkey);
      _getDataFromHash();
    }

    if (data.witness != null) {
      if (data.witness.length != 2)
        throw new ArgumentError('Witness is invalid');
      if (!bscript.isCanonicalScriptSignature(data.witness[0]))
        throw new ArgumentError('Witness has invalid signature');
      if (!isPoint(data.witness[1]))
        throw new ArgumentError('Witness has invalid pubkey');
      _getDataFromWitness(data.witness);
    } else if (data.pubkey != null && data.signature != null) {
      data.witness = [data.signature, data.pubkey];
      if (data.input == null) data.input = EMPTY_SCRIPT;
    }
  }

  void _getDataFromWitness([List<Uint8List> witness]) {
    if (data.input == null) {
      data.input = EMPTY_SCRIPT;
    }
    if (data.pubkey == null) {
      data.pubkey = witness[1];
      if (data.hash == null) {
        data.hash = Cryptor.hash160(data.pubkey);
      }
      _getDataFromHash();
    }
    if (data.signature == null) data.signature = witness[0];
  }

  void _getDataFromHash() {
    if (data.address == null) {
      data.address = segwit.encode(Segwit(network.bech32, 0, data.hash));
    }
    if (data.output == null) {
      data.output = bscript.compile([OPS['OP_0'], data.hash]);
    }
  }

  void _getDataFromAddress(String address) {
    try {
      Segwit _address = segwit.decode(address);
      if (network.bech32 != _address.hrp)
        throw new ArgumentError('Invalid prefix or Network mismatch');
      if (_address.version != 0) // Only support version 0 now;
        throw new ArgumentError('Invalid address version');
      data.hash = Uint8List.fromList(_address.program);
    } on InvalidHrp {
      throw new ArgumentError('Invalid prefix or Network mismatch');
    } on InvalidProgramLength {
      throw new ArgumentError('Invalid address data');
    } on InvalidWitnessVersion {
      throw new ArgumentError('Invalid witness address version');
    }
  }
}

final NetworkType bitcoin = new NetworkType(
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'bc',
    bip32: new Bip32Type(public: 0x0488b21e, private: 0x0488ade4),
    pubKeyHash: 0x00,
    scriptHash: 0x05,
    wif: 0x80);

final NetworkType bitcoinTestnet = new NetworkType(
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'tb',
    bip32: new Bip32Type(public: 0x043587cf, private: 0x04358394),
    pubKeyHash: 0x6f,
    scriptHash: 0xc4,
    wif: 0xef);

final NetworkType litecoin = new NetworkType(
    messagePrefix: '\x19Litecoin Signed Message:\n',
    bech32: 'ltc',
    bip32: new Bip32Type(public: 0x019da462, private: 0x019d9cfe),
    pubKeyHash: 0x30,
    scriptHash: 0x32,
    wif: 0xb0);

final NetworkType litecoinTestnet = new NetworkType(
    messagePrefix: '\x19Litecoin Signed Message:\n',
    bech32: 'tltc',
    bip32: new Bip32Type(public: 0x019da462, private: 0x019d9cfe),
    pubKeyHash: 0x30,
    scriptHash: 0x32,
    wif: 0xb0);

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
  List<int> publicKey = pubKey.length > 33 ? compressedPubKey(pubKey) : pubKey;
  List<int> pubKeyHash = Cryptor.hash160(publicKey);
  return pubKeyHash;
}

Uint8List toP2pkhScript(List<int> pubKeyHash) {
  // Pubkey Hash to P2PKH Script
  List<int> data = [];
  data.add(OPS['OP_DUP']); //0x76;
  data.add(OPS['OP_HASH160']); // 0xa9;
  data.add(pubKeyHash.length);
  data.addAll(pubKeyHash);
  data.add(OPS['OP_EQUALVERIFY']); //0x88;
  data.add(OPS['OP_CHECKSIG']); // 0xac；
  return Uint8List.fromList(data);
}

Uint8List toP2shScript(List<int> sriptHash) {
  // Pubkey Hash to P2PKH Script
  List<int> data = [];
  data.add(OPS['OP_HASH160']);
  data.add(sriptHash.length);
  data.addAll(sriptHash);
  data.add(OPS['OP_EQUAL']);
  return Uint8List.fromList(data);
}

Uint8List toP2pkScript(List<int> pubKey) {
  List<int> publicKey = pubKey.length > 33 ? compressedPubKey(pubKey) : pubKey;
  List<int> data = [];
  data.add(publicKey.length);
  data.addAll(publicKey);
  data.add(OPS['OP_CHECKSIG']);
  return Uint8List.fromList(data);
}

Uint8List pubkeyToBIP49RedeemScript(List<int> pubKey) {
  List<int> pubKeyHash = toPubKeyHash(pubKey);
  List<int> rs = [OPS['OP_0'], pubKeyHash.length];
  rs.addAll(pubKeyHash);
  return Uint8List.fromList(rs);
}

//44
String pubKeyToP2pkhAddress(List<int> pubKey, int p2pkhAddressPrefix) {
  final List<int> fingerprint = toPubKeyHash(pubKey);
  final List<int> hashPubKey =
      Uint8List.fromList([p2pkhAddressPrefix] + fingerprint);
  final String address = bs58check.encode(hashPubKey);
  return address;
}

String pubKeyToP2pkhCashAddress(List<int> pubKey, int p2pkhAddressPrefix) {
  // Compressed Public Key to P2PKH Cash Address
  String lagacyAddress = pubKeyToP2pkhAddress(pubKey, p2pkhAddressPrefix);
  String address = Address.toCashAddress(lagacyAddress, true);
  Log.debug('cashAddress: $address');
  return address;
}

//84
String pubKeyToP2wpkhAddress(List<int> pubKey, String bech32Hrp) {
  String address;
  if (bech32Hrp == 'bc') {
    address = P2WPKH(
            data: PaymentData(pubkey: Uint8List.fromList(pubKey)),
            network: bitcoin)
        .data
        .address;
  } else if (bech32Hrp == 'tb') {
    address = P2WPKH(
            data: PaymentData(pubkey: Uint8List.fromList(pubKey)),
            network: bitcoinTestnet)
        .data
        .address;
  } else if (bech32Hrp == 'ltc') {
    address = P2WPKH(
            data: PaymentData(pubkey: Uint8List.fromList(pubKey)),
            network: litecoin)
        .data
        .address;
  } else if (bech32Hrp == 'tltc') {
    address = P2WPKH(
            data: PaymentData(pubkey: Uint8List.fromList(pubKey)),
            network: litecoinTestnet)
        .data
        .address;
  }
  return address;
}

//49
String pubKeyToP2wpkhNestedInP2shAddress(
    List<int> pubKey, int p2shAddressPrefix) {
  List<int> redeemScript = pubkeyToBIP49RedeemScript(pubKey);
  List<int> fingerprint = Cryptor.hash160(redeemScript);
  // List<int> checksum = sha256(sha256(fingerprint)).sublist(0, 4);
  // bs58check library 會幫加checksum
  String address =
      bs58check.encode(Uint8List.fromList([p2shAddressPrefix] + fingerprint));

  return address;
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
  // Log.debug('scriptPubKey: $scriptPubKey');
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
