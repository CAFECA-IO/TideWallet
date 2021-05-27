part of 'account_currency_bloc.dart';

@immutable
abstract class AccountCurrencyEvent extends Equatable {
  const AccountCurrencyEvent();
  @override
  List<Object> get props => [];
}

class GetCurrencyList extends AccountCurrencyEvent {
  @override
  List<Object> get props => [];
}

class UpdateAccountCurrencies extends AccountCurrencyEvent {
  final List<Currency> currencies;

  UpdateAccountCurrencies(this.currencies);
}

class CleanAccountCurrencies extends AccountCurrencyEvent {
  @override
  List<Object> get props => [];
}

class ToggleDisplay extends AccountCurrencyEvent {
  final String currencyId;

  ToggleDisplay(this.currencyId);
}