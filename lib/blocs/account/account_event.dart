part of 'account_bloc.dart';

@immutable
abstract class AccountEvent extends Equatable {
  const AccountEvent();
  @override
  List<Object> get props => [];
}

class OverView extends AccountEvent {
  @override
  List<Object> get props => [];
}

class UpdateAccounts extends AccountEvent {
  final List<Account> accounts;
  final String totalBalanceInFiat;
  final Fiat? fiat;
  UpdateAccounts(
      {required this.totalBalanceInFiat, required this.accounts, this.fiat});
}

class CleanAccounts extends AccountEvent {
  @override
  List<Object> get props => [];
}

class ToggleDisplay extends AccountEvent {
  final String currencyId;

  ToggleDisplay(this.currencyId);
}
