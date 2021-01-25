part of 'transaction_status_bloc.dart';

abstract class TransactionStatusEvent extends Equatable {
  const TransactionStatusEvent();

  @override
  List<Object> get props => [];
}

class UpdateCurrency extends TransactionStatusEvent {
  final Currency currency;
  UpdateCurrency(this.currency);
}

class GetTransactionList extends TransactionStatusEvent {
  final Currency currency;

  GetTransactionList(this.currency);
}

class UpdateTransactionList extends TransactionStatusEvent {
  final Currency currency;
  final List<Transaction> transactions;

  UpdateTransactionList(this.currency, this.transactions);
}

class UpdateTransaction extends TransactionStatusEvent {
  final Transaction transaction;

  UpdateTransaction(this.transaction);
}
