import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tidewallet3/cores/paper_wallet.dart';
import 'package:tidewallet3/cores/signer.dart';
import 'package:tidewallet3/helpers/cryptor.dart';
import 'package:tidewallet3/helpers/logger.dart';
import 'package:tidewallet3/helpers/utils.dart';
import 'package:bs58check/bs58check.dart' as bs58check;

void main() {
  String rawTransaction =
      '0xd46e8dd67c5d32be8d46e8dd67c5d32be8058bb8eb970870f072445675058bb8eb970870f072445675';
  String privKey =
      '929cb0a76cccbb93283832c5833d53ce7048c085648eb367a9e63c44c146b35d';
  test('sign', () {
    Uint8List rawTxHash = Uint8List.fromList(Cryptor.keccak256round(
        hex.decode(stripHexPrefix(rawTransaction)),
        round: 1));
    MsgSignature signature =
        Signer().sign(rawTxHash, Uint8List.fromList(hex.decode(privKey)));
    print('ETH signature r: ${signature.r}');
    print('ETH signature s: ${signature.s}');
  });
}
