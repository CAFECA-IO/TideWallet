part of 'account_list_bloc.dart';

@immutable
abstract class AccountListEvent extends Equatable {
  const AccountListEvent();
  @override
  List<Object> get props => [];
}

class OverView extends AccountListEvent {
  @override
  List<Object> get props => [];
}

class UpdateAccounts extends AccountListEvent {
  final List<Account> accounts;
  final String? totalBalanceInFiat;
  final Fiat? fiat;
  UpdateAccounts({this.totalBalanceInFiat, required this.accounts, this.fiat});
}

class CleanAccounts extends AccountListEvent {
  @override
  List<Object> get props => [];
}

class ToggleDisplay extends AccountListEvent {
  final String currencyId;

  ToggleDisplay(this.currencyId);
}
