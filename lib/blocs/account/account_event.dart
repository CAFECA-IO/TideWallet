part of 'account_bloc.dart';

@immutable
abstract class AccountEvent extends Equatable {
  const AccountEvent();
  @override
  List<Object> get props => [];
}

class GetAccountList extends AccountEvent {
  @override
  List<Object> get props => [];
}

class UpdateAccounts extends AccountEvent {
  final List<Account> accounts;

  UpdateAccounts(this.accounts);
}

class CleanAccounts extends AccountEvent {
  @override
  List<Object> get props => [];
}

class ToggleDisplay extends AccountEvent {
  final String currencyId;

  ToggleDisplay(this.currencyId);
}
