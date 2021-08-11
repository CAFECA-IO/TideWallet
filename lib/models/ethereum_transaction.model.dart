import 'dart:typed_data';

import 'package:decimal/decimal.dart';

import 'transaction.model.dart';

import '../helpers/ethereum_based_utils.dart';
import '../cores/signer.dart';

class EthereumTransaction extends Transaction {
  late String? id;
  late String currencyId;
  late TransactionDirection direction;
  late Decimal amount; // in Wei
  late TransactionStatus? status;
  late int? timestamp; // in second //TODO uncheck
  late int? confirmations;
  // late String _address;
  late Decimal fee; // in Wei
  late String? txId;
  late Uint8List? message; // utf8.encode
  late String sourceAddresses;
  late String destinationAddresses;

  String from;
  final String to;
  final int nonce;
  int? block;
  final Decimal gasPrice; // in Wei
  final Decimal gasUsed;
  int? chainId;
  MsgSignature signature;

  EthereumTransaction({
    this.id,
    required this.currencyId,
    this.txId,
    required this.from,
    required this.to,
    required this.nonce,
    required this.amount,
    required this.gasPrice,
    required this.gasUsed,
    required this.fee,
    required this.signature,
    this.timestamp,
    this.confirmations,
    this.status,
    this.block,
    this.message,
    this.chainId,
  });

  EthereumTransaction.prepareTransaction(
      {required this.from,
      required this.to,
      required this.nonce,
      required this.amount,
      required this.gasPrice,
      required this.gasUsed,
      this.message,
      this.chainId,
      required this.fee,
      required this.signature}) {
    this.direction = TransactionDirection.sent;
    this.status = TransactionStatus.pending;
    this.destinationAddresses = this.to;
    this.sourceAddresses = this.from;
  }

  @override
  Uint8List get serializeTransaction => encodeToRlp(this);
}
