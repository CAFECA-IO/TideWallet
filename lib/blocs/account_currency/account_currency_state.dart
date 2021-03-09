part of 'account_currency_bloc.dart';

@immutable
abstract class AccountCurrencyState extends Equatable {
  final List<Currency> currencies;
  final Decimal total;
  const AccountCurrencyState(this.currencies, {this.total});

  @override
  List<Object> get props => [];
}

class AccountCurrencyInitial extends AccountCurrencyState {
  final Decimal total;

  AccountCurrencyInitial(List<Currency> currencies, {this.total})
      : super(currencies);
}

class AccountCurrencyLoaded extends AccountCurrencyState {
  final List<Currency> currencies;
  final Decimal total;

  AccountCurrencyLoaded(this.currencies, {this.total})
      : super([], total: Decimal.zero);

  @override
  List<Object> get props => [currencies, total];
}
