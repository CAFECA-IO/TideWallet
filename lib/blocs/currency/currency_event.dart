part of 'currency_bloc.dart';

abstract class CurrencyEvent extends Equatable {
  const CurrencyEvent();

  @override
  List<Object> get props => [];
}

class GetCurrencyList extends CurrencyEvent {
  final String accountId;

  GetCurrencyList(this.accountId);
}

class UpdateCurrencies extends CurrencyEvent {
  final List<Currency> currenices;

  UpdateCurrencies(this.currenices);
}

class CleanCurrencie extends CurrencyEvent {
  @override
  List<Object> get props => [];
}
