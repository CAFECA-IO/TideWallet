part of 'currency_bloc.dart';

abstract class CurrencyState extends Equatable {
  final List<Currency> currencies;
  final Decimal total;
  const CurrencyState(this.currencies, {this.total});

  @override
  List<Object> get props => [];
}

class CurrencyInitial extends CurrencyState {
  final Decimal total;

  CurrencyInitial(List<Currency> currencies, {this.total}) : super(currencies);
}

class CurrencyLoaded extends CurrencyState {
  final List<Currency> currencies;
  final Decimal total;

  CurrencyLoaded(this.currencies, {this.total}) : super([], total: Decimal.zero);
}
