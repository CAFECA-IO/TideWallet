part of 'transaction_status_bloc.dart';

abstract class TransactionStatusState extends Equatable {
  final Account? account;
  final List<Transaction> transactions;
  final Transaction? transaction;

  const TransactionStatusState(
      this.account, this.transactions, this.transaction);

  @override
  List<Object> get props => [];
}

class TransactionStatusInitial extends TransactionStatusState {
  TransactionStatusInitial(Account? account, List<Transaction> transactions,
      Transaction? transaction)
      : super(account, transactions, transaction);

  @override
  List<Object> get props => [];
}

class TransactionStatusLoaded extends TransactionStatusState {
  TransactionStatusLoaded(
      Account account, List<Transaction> transactions, Transaction? transaction)
      : super(account, transactions, transaction);

  @override
  List<Object> get props => [account!, transactions, transaction!];
}
