part of 'account_detail_bloc.dart';

abstract class AccountDetailState extends Equatable {
  final Account? account;
  final Account? shareAccount;
  final List<Transaction>? transactions;

  const AccountDetailState(this.account, this.shareAccount, this.transactions);

  @override
  List<Object> get props => [];
}

class AccountDetailInitial extends AccountDetailState {
  AccountDetailInitial() : super(null, null, []);

  @override
  List<Object> get props => [];
}

class AccountDetailLoaded extends AccountDetailState {
  final Account account;
  final Account shareAccount;
  final List<Transaction> transactions;
  AccountDetailLoaded(this.account, this.shareAccount, this.transactions)
      : super(account, shareAccount, transactions);

  @override
  List<Object> get props => [account, shareAccount, transactions];
}

class TransactionLoaded extends AccountDetailState {
  final Account account;
  final Account shareAccount;
  final Transaction transaction;
  TransactionLoaded(this.account, this.shareAccount, this.transaction,
      {List<Transaction>? transactions})
      : super(account, shareAccount, transactions);

  @override
  List<Object> get props => [account, shareAccount, transaction];
}
