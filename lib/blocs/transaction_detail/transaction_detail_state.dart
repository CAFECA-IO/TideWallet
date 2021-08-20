part of 'transaction_detail_bloc.dart';

abstract class TransactionDetailState extends Equatable {
  final Account? account;
  final Account? shareAccount;
  final Transaction? transaction;
  const TransactionDetailState(
      this.account, this.shareAccount, this.transaction);

  @override
  List<Object> get props => [];
}

class TransactionDetailInitial extends TransactionDetailState {
  TransactionDetailInitial() : super(null, null, null);
}

class TransactionLoaded extends TransactionDetailState {
  final Account account;
  final Account shareAccount;
  final Transaction transaction;
  TransactionLoaded(
    this.account,
    this.shareAccount,
    this.transaction,
  ) : super(account, shareAccount, transaction);

  @override
  List<Object> get props => [account, shareAccount, transaction];
}
