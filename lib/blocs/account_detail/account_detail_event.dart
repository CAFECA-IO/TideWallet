part of 'account_detail_bloc.dart';

abstract class AccountDetailEvent extends Equatable {
  const AccountDetailEvent();

  @override
  List<Object> get props => [];
}

class GetAccountDetail extends AccountDetailEvent {
  final String accountId;
  GetAccountDetail(this.accountId);
}

class UpdateAccount extends AccountDetailEvent {
  final Account account;
  UpdateAccount(this.account);
}

class UpdateTransactionList extends AccountDetailEvent {
  final Account account;
  final List<Transaction> transactions;

  UpdateTransactionList(this.account, this.transactions);
}

class UpdateTransaction extends AccountDetailEvent {
  final Account account;
  final Transaction transaction;

  UpdateTransaction(this.account, this.transaction);
}
