part of 'account_bloc.dart';

@immutable
abstract class AccountState extends Equatable {
  final List<Account> accounts;
  final Decimal total;
  const AccountState(this.accounts, {required this.total});

  @override
  List<Object> get props => [];
}

class AccountInitial extends AccountState {
  final Decimal total;

  AccountInitial(List<Account> accounts, {required this.total})
      : super(accounts, total: total);
}

class AccountLoaded extends AccountState {
  final List<Account> accounts;
  final Decimal total;

  AccountLoaded(this.accounts, {required this.total})
      : super([], total: Decimal.zero);

  @override
  List<Object> get props => [accounts, total];
}
