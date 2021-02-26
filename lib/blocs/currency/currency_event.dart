part of 'currency_bloc.dart';

abstract class CurrencyEvent extends Equatable {
  const CurrencyEvent();

  @override
  List<Object> get props => [];
}

class GetCurrencyList extends CurrencyEvent {
  final ACCOUNT account;

  GetCurrencyList(this.account);
}

class UpdateCurrencies extends CurrencyEvent {
  final List<Currency> currenices;

  UpdateCurrencies(this.currenices);
}

class CleanCurrencie extends CurrencyEvent {
  @override
  List<Object> get props => [];
}