import 'db_transaction.model.dart';
import './transaction.model.dart';

class EthereumTokenTransaction {
  final String id;
  final String txHash;
  final String from;
  final String to;
  int timestamp;
  int confirmations;
  TransactionStatus status;
  final String amount;
  final String tokenId;

  final String ownerAddress;
  final String ownerContract;

  EthereumTokenTransaction({
    this.id,
    this.txHash,
    this.from,
    this.to,
    this.timestamp,
    this.confirmations,
    this.status,
    this.amount,
    this.tokenId, // for ERC-721
    this.ownerAddress,
    this.ownerContract,
  });

  EthereumTokenTransaction.fromMap(Map<String, dynamic> transactionMap)
      : id = transactionMap[DBTransaction.FieldName_Id],
        txHash = transactionMap[DBTransaction.FieldName_TxId],
        from = transactionMap[DBTransaction.FieldName_SourceAddresses],
        to = transactionMap[DBTransaction.FieldName_DesticnationAddresses],
        timestamp = transactionMap[DBTransaction.FieldName_Timestamp],
        confirmations = transactionMap[DBTransaction.FieldName_Confirmations],
        status = transactionMap[DBTransaction.FieldName_Status],
        amount = transactionMap[DBTransaction.FieldName_Amount],
        tokenId = transactionMap[DBTransaction.FieldName_TokenId],
        ownerAddress = transactionMap[DBTransaction.FieldName_OwnerAddress],
        ownerContract = transactionMap[DBTransaction.FieldName_OwnerContract];
}
