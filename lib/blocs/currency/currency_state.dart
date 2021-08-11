part of 'currency_bloc.dart';

abstract class CurrencyState extends Equatable {
  final List<Currency> currencies;
  final Decimal total;
  const CurrencyState(this.currencies, {required this.total});

  @override
  List<Object> get props => [];
}

class CurrencyInitial extends CurrencyState {
  final Decimal total;

  CurrencyInitial(List<Currency> currencies, {required this.total})
      : super(currencies, total: total);
}

class CurrencyLoaded extends CurrencyState {
  final List<Currency> currencies;
  final Decimal total;

  CurrencyLoaded(this.currencies, {required this.total})
      : super([], total: Decimal.zero);

  @override
  List<Object> get props => [currencies, total];
}
