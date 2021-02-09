import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:convert/convert.dart';

import 'transaction.model.dart';
import 'db_transaction.model.dart';

import '../helpers/ethereum_based_utils.dart';
import '../cores/signer.dart';

class EthereumTransaction extends Transaction {
  String id;
  String currencyId;
  String txHash;
  final String from;
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

  EthereumTransaction.fromMap(Map<String, dynamic> transactionMap)
      : id = transactionMap[DBTransaction.FieldName_Id],
        currencyId = transactionMap[DBTransaction.FieldName_CurrencyId],
        txHash = transactionMap[DBTransaction.FieldName_TxId],
        from = transactionMap[DBTransaction.FieldName_SourceAddresses],
        to = transactionMap[DBTransaction.FieldName_DesticnationAddresses],
        timestamp = transactionMap[DBTransaction.FieldName_Timestamp],
        nonce = transactionMap[DBTransaction.FieldName_Nonce],
        confirmations = transactionMap[DBTransaction.FieldName_Confirmations],
        block = transactionMap[DBTransaction.FieldName_Block],
        amount = Decimal.parse(transactionMap[DBTransaction.FieldName_Amount]),
        gasPrice =
            Decimal.parse(transactionMap[DBTransaction.FieldName_GasPrice]),
        gasUsed =
            Decimal.parse(transactionMap[DBTransaction.FieldName_GasUsed]),
        message = transactionMap[DBTransaction.FieldName_Note];

  EthereumTransaction.prepareTransaction(
      {this.from,
      this.to,
      this.nonce,
      this.amount,
      this.gasPrice,
      this.gasUsed,
      this.message,
      this.chainId,
      this.signature});

  String get serializeTransaction => hex.encode(encodeToRlp(this));
}
