import 'dart:typed_data';

import 'transaction.model.dart';
import 'db_transaction.model.dart';

abstract class BitcoinTransaction {
  String id;
  String txid;
  int locktime;
  int timestamp;
  int confirmations;
  TransactionDirection direction;
  TransactionStatus status;
  String sourceAddresses;
  String destinationAddresses;
  String amount;
  String fee;
  Uint8List note;

  BitcoinTransaction({
    this.id,
    this.txid,
    this.locktime,
    this.timestamp,
    this.confirmations,
    this.direction,
    this.status,
    this.sourceAddresses,
    this.destinationAddresses,
    this.amount,
    this.fee,
    this.note,
  });

  BitcoinTransaction.fromMap(Map<String, dynamic> transactionMap)
      : id = transactionMap[DBTransaction.FieldName_Id],
        txid = transactionMap[DBTransaction.FieldName_TxId],
        sourceAddresses =
            transactionMap[DBTransaction.FieldName_SourceAddresses],
        destinationAddresses =
            transactionMap[DBTransaction.FieldName_DesticnationAddresses],
        timestamp = transactionMap[DBTransaction.FieldName_Timestamp],
        confirmations = transactionMap[DBTransaction.FieldName_Confirmations],
        amount = transactionMap[DBTransaction.FieldName_Amount].toString(),
        direction = TransactionDirection.values.firstWhere((element) =>
            element.value == transactionMap[DBTransaction.FieldName_Direction]),
        locktime = transactionMap[DBTransaction.FieldName_LockedTime],
        fee = transactionMap[DBTransaction.FieldName_Fee].toString(),
        note = transactionMap[DBTransaction.FieldName_Note],
        status = transactionMap[DBTransaction.FieldName_Status];
}
