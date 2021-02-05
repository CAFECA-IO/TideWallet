import 'dart:typed_data';

import 'package:decimal/decimal.dart';

import 'transaction.model.dart';
import 'db_transaction.model.dart';

class EthereumTransaction extends Transaction {
  final String id;
  final String currencyId;
  final String txHash;
  final String from;
  final String to;
  final int timestamp;
  int confirmations;
  TransactionStatus status;
  final int nonce;
  final int block;
  final Decimal amount; // in Wei
  final String gasPrice; // in Wei
  final int gasUsed;
  final Uint8List data; // utf8.encode

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
    Uint8List data,
  }) : data = data ?? Uint8List(0);

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
        amount = transactionMap[DBTransaction.FieldName_Amount],
        gasPrice = transactionMap[DBTransaction.FieldName_GasPrice].toString(),
        gasUsed = transactionMap[DBTransaction.FieldName_GasUsed],
        data = transactionMap[DBTransaction.FieldName_Note];

  EthereumTransaction.prepareTransaction(
      {this.id,
      this.currencyId,
      this.txHash,
      this.from,
      this.to,
      this.timestamp,
      this.nonce,
      this.block,
      this.amount,
      this.gasPrice,
      this.gasUsed,
      this.data}) {
    // TODO
  }

  String get hex {
    // TODO use Ethterum
    return '01000000010000000000000000000000000000000000000000000000000000000000000000ffffffff2d03a58605204d696e656420627920416e74506f6f6c20757361311f10b53620558903d80272a70c0000724c0600ffffffff010f9e5096000000001976a9142ef12bd2ac1416406d0e132e5bc8d0b02df3861b88ac00000000';
  }
}
