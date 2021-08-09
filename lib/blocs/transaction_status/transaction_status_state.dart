part of 'transaction_status_bloc.dart';

abstract class TransactionStatusState extends Equatable {
  final Currency? currency;
  final List<Transaction> transactions;
  final Transaction? transaction;

  const TransactionStatusState(
      this.currency, this.transactions, this.transaction);

  @override
  List<Object> get props => [];
}

class TransactionStatusInitial extends TransactionStatusState {
  TransactionStatusInitial(Currency? currency, List<Transaction> transactions,
      Transaction? transaction)
      : super(currency, transactions, transaction);

  @override
  List<Object> get props => [];
}

class TransactionStatusLoaded extends TransactionStatusState {
  TransactionStatusLoaded(Currency currency, List<Transaction> transactions,
      Transaction? transaction)
      : super(currency, transactions, transaction);

  @override
  List<Object> get props => [currency!, transactions, transaction!];
}
