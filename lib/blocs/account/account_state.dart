part of 'account_bloc.dart';

@immutable
abstract class AccountState extends Equatable {
  final List<Currency> accounts;
  final Decimal total; 

  AccountState(this.accounts, { this.total });
}

class AccountInitial extends AccountState {
  AccountInitial() : super([], total: Decimal.zero);
  @override
  List<Object> get props => [];
}


class AccountLoaded extends AccountState {
  final List<Currency> accounts;
  final Decimal total; 

  AccountLoaded(this.accounts, { this.total }) : super([]);

  @override
  List<Object> get props => [accounts];
}