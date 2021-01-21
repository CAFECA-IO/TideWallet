part of 'account_bloc.dart';

@immutable
abstract class AccountState extends Equatable {
  final List<Account> accounts;
  AccountState(this.accounts);
}

class AccountInitial extends AccountState {
  AccountInitial() : super([]);
  @override
  List<Object> get props => [];
}


class AccountLoaded extends AccountState {
  final List<Account> accounts;
  AccountLoaded(this.accounts) : super([]);

  @override
  List<Object> get props => [accounts];
}