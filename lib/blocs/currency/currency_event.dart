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

class UpdateCurrency extends CurrencyEvent {
  final Currency token;

  UpdateCurrency(this.token);
}