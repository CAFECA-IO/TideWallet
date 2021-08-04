import 'dart:math';
import 'dart:typed_data';

// import 'package:bip39/bip39.dart';
import 'package:crypto/crypto.dart' show sha256;
import 'package:convert/convert.dart';
import 'wordList/es.dart';
import 'wordList/fa.dart';
import 'wordList/it.dart';
import 'wordList/ja_jp.dart';
import 'wordList/ko.dart';
import 'wordList/zh_cn.dart';
import 'wordList/en.dart';
import 'wordList/zh_tw.dart';

typedef Uint8List RandomBytes(int size);

const _WORDLIST = [fa, it, ja_jp, ko, es, zh_cn, zh_tw, en];

const int _SIZE_BYTE = 255;
const _INVALID_MNEMONIC = 'Invalid mnemonic';
const _INVALID_ENTROPY = 'Invalid entropy';
const _INVALID_CHECKSUM = 'Invalid mnemonic checksum';

int _binaryToByte(String binary) {
  return int.parse(binary, radix: 2);
}

String _bytesToBinary(Uint8List bytes) {
  return bytes.map((byte) => byte.toRadixString(2).padLeft(8, '0')).join('');
}

Uint8List _randomBytes(int size) {
  final rng = Random.secure();
  final bytes = Uint8List(size);
  for (var i = 0; i < size; i++) {
    bytes[i] = rng.nextInt(_SIZE_BYTE);
  }
  return bytes;
}

String _deriveChecksumBits(Uint8List entropy) {
  final ent = entropy.length * 8;
  final cs = ent ~/ 32;
  final hash = sha256.convert(entropy);
  return _bytesToBinary(Uint8List.fromList(hash.bytes)).substring(0, cs);
}

String eXgenerateMnemonic(
    {int length, RandomBytes randomBytes = _randomBytes, String lang}) {
  assert(length != null);
  final strength = (length ~/ 3 * 32);
  assert(strength % 32 == 0);
  final entropy = randomBytes(strength ~/ 8);
  return eXentropyToMnemonic(hex.encode(entropy), lang: lang);
}

String eXentropyToMnemonic(String entropyString, {String lang = 'English'}) {
  final entropy = hex.decode(entropyString);
  if (entropy.length < 16) {
    throw ArgumentError(_INVALID_ENTROPY);
  }
  if (entropy.length > 32) {
    throw ArgumentError(_INVALID_ENTROPY);
  }
  if (entropy.length % 4 != 0) {
    throw ArgumentError(_INVALID_ENTROPY);
  }
  final entropyBits = _bytesToBinary(entropy);
  final checksumBits = _deriveChecksumBits(entropy);
  final bits = entropyBits + checksumBits;
  final regex = new RegExp(r".{1,11}", caseSensitive: false, multiLine: false);
  final chunks = regex
      .allMatches(bits)
      .map((match) => match.group(0))
      .toList(growable: false);
  List<String> wordlist = _loadWordList(lang);
  String words =
      chunks.map((binary) => wordlist[_binaryToByte(binary)]).join(' ');
  return words;
}

bool eXvalidateMnemonic(String mnemonic) {
  try {
    eXmnemonicToEntropy(mnemonic);
  } catch (e) {
    return false;
  }
  return true;
}

String eXmnemonicToEntropy(mnemonic, {String lang}) {
  var words = mnemonic.split(' ');
  if (words.length % 3 != 0) {
    throw new ArgumentError(_INVALID_MNEMONIC);
  }

  var bits;
  var wordlist;
  if (lang != null) {
    wordlist = _loadWordList(lang);
  }

  bool matched = false;

  for (var i = 0; i < _WORDLIST.length; i++) {
    for (var j = 0; j < words.length; j++) {
      if (_WORDLIST[i].indexOf(words[j]) == -1) {
        matched = false;
        break;
      } else {
        matched = true;
      }
    }
    if (matched) {
      wordlist = _WORDLIST[i];
      break;
    }
  }

  if (wordlist == null) {
    throw StateError(_INVALID_CHECKSUM);
  }

  bits = words.map((word) {
    final index = wordlist.indexOf(word);
    if (index == -1) {
      throw new ArgumentError(_INVALID_MNEMONIC);
    }
    return index.toRadixString(2).padLeft(11, '0');
  }).join('');

  // split the binary string into ENT/CS
  final dividerIndex = (bits.length / 33).floor() * 32;
  final entropyBits = bits.substring(0, dividerIndex);
  final checksumBits = bits.substring(dividerIndex);

  // calculate the checksum and compare
  final regex = RegExp(r".{1,8}");
  final entropyBytes = Uint8List.fromList(regex
      .allMatches(entropyBits)
      .map((match) => _binaryToByte(match.group(0)))
      .toList(growable: false));
  if (entropyBytes.length < 16) {
    throw StateError(_INVALID_ENTROPY);
  }
  if (entropyBytes.length > 32) {
    throw StateError(_INVALID_ENTROPY);
  }
  if (entropyBytes.length % 4 != 0) {
    throw StateError(_INVALID_ENTROPY);
  }
  final newChecksum = _deriveChecksumBits(entropyBytes);
  if (newChecksum != checksumBits) {
    throw StateError(_INVALID_CHECKSUM);
  }
  return entropyBytes.map((byte) {
    return byte.toRadixString(16).padLeft(2, '0');
  }).join('');
}

List<String> _loadWordList(String lang) {
  switch (lang) {
    case 'Français':
      return _WORDLIST[0];
      break;
    case 'Italiano':
      return _WORDLIST[1];
      break;
    case '日本語':
      return _WORDLIST[2];
      break;
    case '한국어':
      return _WORDLIST[3];
      break;
    case 'Español':
      return _WORDLIST[4];
      break;
    case '简体中文':
      return _WORDLIST[5];
      break;
    case '繁體中文':
      return _WORDLIST[6];
      break;
    case 'English':
      return _WORDLIST[7];
  }

  return [];
}
