part of 'transaction_status_bloc.dart';

abstract class TransactionStatusEvent extends Equatable {
  const TransactionStatusEvent();

  @override
  List<Object> get props => [];
}

class UpdateAccount extends TransactionStatusEvent {
  final Account account;
  UpdateAccount(this.account);
}

class GetTransactionList extends TransactionStatusEvent {
  final Account account;

  GetTransactionList(this.account);
}

class UpdateTransactionList extends TransactionStatusEvent {
  final Account account;
  final List<Transaction> transactions;

  UpdateTransactionList(this.account, this.transactions);
}

class UpdateTransaction extends TransactionStatusEvent {
  final Transaction transaction;

  UpdateTransaction(this.transaction);
}
