import 'db_transaction.model.dart';
import './transaction.model.dart';

class EthereumTokenTransaction {
  final String id;
  final String currencyId;
  final String txHash;
  final String from;
  final String to;
  int timestamp;
  int confirmations;
  TransactionStatus status;
  final String amount;

  EthereumTokenTransaction({
    this.id,
    this.currencyId,
    this.txHash,
    this.from,
    this.to,
    this.timestamp,
    this.confirmations,
    this.status,
    this.amount,
  });

  EthereumTokenTransaction.fromMap(Map<String, dynamic> transactionMap)
      : id = transactionMap[DBTransaction.FieldName_Id],
        currencyId = transactionMap[DBTransaction.FieldName_CurrencyId],
        txHash = transactionMap[DBTransaction.FieldName_TxId],
        from = transactionMap[DBTransaction.FieldName_SourceAddresses],
        to = transactionMap[DBTransaction.FieldName_DesticnationAddresses],
        timestamp = transactionMap[DBTransaction.FieldName_Timestamp],
        confirmations = transactionMap[DBTransaction.FieldName_Confirmations],
        status = transactionMap[DBTransaction.FieldName_Status],
        amount = transactionMap[DBTransaction.FieldName_Amount];
}
