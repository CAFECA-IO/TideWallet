part of 'transaction_status_bloc.dart';

abstract class TransactionStatusState extends Equatable {
  final Currency currency;
  final List<Transaction> transactions;

  const TransactionStatusState(this.currency, this.transactions);

  @override
  List<Object> get props => [];
}

class TransactionStatusInitial extends TransactionStatusState {
  TransactionStatusInitial(Currency currency, List<Transaction> transactions)
      : super(currency, transactions);

  @override
  List<Object> get props => [];
}

class TransactionStatusLoaded extends TransactionStatusState {
  TransactionStatusLoaded(Currency currency, List<Transaction> transactions)
      : super(currency, transactions);

  @override
  List<Object> get props => [currency, transactions];
}
