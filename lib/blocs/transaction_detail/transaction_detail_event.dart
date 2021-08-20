part of 'transaction_detail_bloc.dart';

abstract class TransactionDetailEvent extends Equatable {
  const TransactionDetailEvent();

  @override
  List<Object> get props => [];
}

class GetTransactionDetial extends TransactionDetailEvent {
  final String accountId;
  final String txid;
  GetTransactionDetial(this.accountId, this.txid);
}

class UpdateTransaction extends TransactionDetailEvent {
  final Account account;
  final Transaction transaction;

  UpdateTransaction(this.account, this.transaction);
}
