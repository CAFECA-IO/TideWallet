part of 'account_currency_bloc.dart';

@immutable
abstract class AccountCurrencyEvent extends Equatable {
  const AccountCurrencyEvent();
  @override
  List<Object> get props => [];
}

class UpdateAccount extends AccountCurrencyEvent {
  final Currency account;

  UpdateAccount(this.account);

  @override
  List<Object> get props => [];
}

class CleanAccount extends AccountCurrencyEvent {
  @override
  List<Object> get props => [];
}

class GetCurrencyList extends AccountCurrencyEvent {
  @override
  List<Object> get props => [];
}

class UpdateCurrencies extends AccountCurrencyEvent {
  final List<Currency> currenices;

  UpdateCurrencies(this.currenices);
}

class CleanCurrencie extends AccountCurrencyEvent {
  @override
  List<Object> get props => [];
}
