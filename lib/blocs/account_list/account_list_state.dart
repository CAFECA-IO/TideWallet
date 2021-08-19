part of 'account_list_bloc.dart';

@immutable
abstract class AccountListState extends Equatable {
  final List<Account> accounts;
  final String totalBalanceInFiat;

  const AccountListState(
      {required this.totalBalanceInFiat, required this.accounts});

  @override
  List<Object> get props => [];
}

class AccountInitial extends AccountListState {
  final List<Account> accounts;
  final String totalBalanceInFiat;

  AccountInitial({required this.totalBalanceInFiat, required this.accounts})
      : super(totalBalanceInFiat: '0', accounts: []);
}

class AccountLoaded extends AccountListState {
  final List<Account> accounts;
  final String totalBalanceInFiat;

  AccountLoaded({required this.totalBalanceInFiat, required this.accounts})
      : super(totalBalanceInFiat: '0', accounts: []);

  @override
  List<Object> get props => [totalBalanceInFiat, accounts];
}
