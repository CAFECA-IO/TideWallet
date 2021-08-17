part of 'account_bloc.dart';

@immutable
abstract class AccountState extends Equatable {
  final List<Account> accounts;
  final String totalBalanceInFiat;
  final Fiat? fiat;
  const AccountState(
      {required this.totalBalanceInFiat, required this.accounts, this.fiat});

  @override
  List<Object> get props => [];
}

class AccountInitial extends AccountState {
  final List<Account> accounts;
  final String totalBalanceInFiat;
  final Fiat? fiat;

  AccountInitial(
      {required this.totalBalanceInFiat, required this.accounts, this.fiat})
      : super(totalBalanceInFiat: '0', accounts: []);
}

class AccountLoaded extends AccountState {
  final List<Account> accounts;
  final String totalBalanceInFiat;
  final Fiat? fiat;

  AccountLoaded(
      {required this.totalBalanceInFiat,
      required this.accounts,
      required this.fiat})
      : super(totalBalanceInFiat: '0', accounts: []);

  @override
  List<Object> get props => [totalBalanceInFiat, accounts, fiat!];
}
