import 'package:decimal/decimal.dart';
import './transaction.model.dart';

class EthereumTokenTransaction extends Transaction {
  final String id;
  final String currencyId;
  final String txHash;
  final String from;
  final String to;
  int timestamp;
  int confirmations;
  TransactionStatus status;
  final Decimal amount;

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
}
