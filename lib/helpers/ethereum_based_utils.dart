import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';

import 'utils.dart';
import 'cryptor.dart';
import 'rlp.dart' as rlp;
import 'logger.dart';
import '../cores/signer.dart';
import '../models/ethereum_transaction.model.dart';

bool isValidFormat(String address) {
  String addr;
  try {
    addr = stripHexPrefix(address);
  } catch (e) {
    return false;
  }
  return RegExp(r"^[0-9a-fA-F]{40}$").hasMatch(addr);
}

String eip55Address(String address) {
  if (!isValidFormat(address)) {
    throw ArgumentError.value(address, "address", "invalid address");
  }

  final String addr = stripHexPrefix(address).toLowerCase();
  Log.debug(hex.encode(Cryptor.keccak256round(hex.decode(address), round: 1)));
  final Uint8List hash = ascii
      .encode(hex.encode(Cryptor.keccak256round(ascii.encode(addr), round: 1)));
  Log.debug(hex.encode(hash));

  var newAddr = "0x";

  for (var i = 0; i < addr.length; i++) {
    if (hash[i] >= 56) {
      newAddr += addr[i].toUpperCase();
    } else {
      newAddr += addr[i];
    }
  }

  return newAddr;
}

Uint8List getEthereumAddressBytes(String address) {
  if (!isValidFormat(address)) {
    throw ArgumentError.value(address, "address", "invalid address");
  }
  final String addr = stripHexPrefix(address).toLowerCase();
  Uint8List buffer = Uint8List.fromList(hex.decode(addr));
  return buffer;
}

bool verifyEthereumAddress(String address) {
  if (address.contains(':')) {
    address = address.split(':')[1];
  }
  if (!isValidFormat(address)) {
    return false;
  }
  address = stripHexPrefix(address);
  // if all lowercase or all uppercase, as in checksum is not present
  if (RegExp(r"^[0-9a-f]{40}$").hasMatch(address) ||
      RegExp(r"^[0-9A-F]{40}$").hasMatch(address)) {
    return true;
  }
  String checksumAddress;
  try {
    checksumAddress = eip55Address(address);
  } catch (err) {
    return false;
  }
  Log.debug(checksumAddress.substring(2));
  Log.debug(address);
  return address == checksumAddress.substring(2);
}

Uint8List encodeToRlpFromJson(Map json, MsgSignature signature) {
  final List<dynamic> list = [
    json['nonce'],
    json['gasPrice'],
    json['gas'],
  ];

  if (json['to'] != null) {
    list.add(getEthereumAddressBytes(json['to']));
  } else {
    list.add('');
  }

  list..add(json['value'])..add(json['data']);

  if (signature != null) {
    list..add(signature.v)..add(signature.r)..add(signature.s);
  }
  Log.debug('ETH list: $list');
  return rlp.encode(list);
}

Uint8List encodeToRlp(EthereumTransaction transaction) {
  final list = [
    transaction.nonce,
    BigInt.parse(transaction.gasPrice.toString()),
    transaction.gasUsed.toInt(),
  ];

  if (transaction.to != null) {
    list.add(transaction.to);
  } else {
    list.add('');
  }

  list
    ..add(BigInt.parse(transaction.amount.toString()))
    ..add(transaction.message);

  if (transaction.signature != null) {
    list
      ..add(transaction.signature.v)
      ..add(transaction.signature.r)
      ..add(transaction.signature.s);
  }
  Log.debug('ETH list: $list');
  return rlp.encode(list);
}
