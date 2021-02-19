import 'dart:typed_data';

import 'package:decimal/decimal.dart';

import 'transaction.model.dart';

import '../helpers/ethereum_based_utils.dart';
import '../cores/signer.dart';

class EthereumTransaction extends Transaction {
  String id;
  String currencyId;
  String txHash;
  String from;
  final String to;
  int timestamp;
  int confirmations;
  TransactionStatus status;
  final int nonce;
  int block;
  final Decimal amount; // in Wei
  final Decimal gasPrice; // in Wei
  final Decimal gasUsed;
  final Uint8List message; // utf8.encode
  int chainId;
  MsgSignature signature;

  EthereumTransaction({
    this.id,
    this.currencyId,
    this.txHash,
    this.from,
    this.to,
    this.timestamp,
    this.nonce,
    this.confirmations,
    this.status,
    this.block,
    this.amount,
    this.gasPrice,
    this.gasUsed,
    Uint8List message,
    this.chainId,
    this.signature,
  }) : message = message ?? Uint8List(0);

  EthereumTransaction.prepareTransaction(
      {
      // this.from,
      this.to,
      this.nonce,
      this.amount,
      this.gasPrice,
      this.gasUsed,
      this.message,
      this.chainId,
      this.signature});

  @override
  Uint8List get serializeTransaction => encodeToRlp(this);
}
