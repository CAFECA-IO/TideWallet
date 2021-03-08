part of 'account_currency_bloc.dart';

@immutable
abstract class AccountCurrencyState extends Equatable {
  final List<Currency> accounts;
  final Decimal total;

  AccountCurrencyState(this.accounts, {this.total});
}

class AccountInitial extends AccountCurrencyState {
  AccountInitial() : super([], total: Decimal.zero);
  @override
  List<Object> get props => [];
}

class AccountLoaded extends AccountCurrencyState {
  final List<Currency> accounts;
  final Decimal total;

  AccountLoaded(this.accounts, {this.total}) : super([]);

  @override
  List<Object> get props => [accounts];
}
