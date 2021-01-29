import 'dart:typed_data';

import 'transaction.model.dart';
import 'db_transaction.model.dart';

class EthereumTransaction {
  final String id;
  final String txHash;
  final String from;
  final String to;
  final int timestamp;
  int confirmations;
  TransactionStatus status;
  final int nonce;
  final int block;
  final String amount; // in Wei
  final String gasPrice; // in Wei
  final int gasUsed;
  final Uint8List data; // utf8.encode

  EthereumTransaction({
    this.id,
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
}
