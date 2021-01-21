part of 'currency_bloc.dart';

abstract class CurrencyState extends Equatable {
  final List<Currency> tokens;
  final Decimal total;
  const CurrencyState(this.tokens, {this.total});

  @override
  List<Object> get props => [];
}

class TokenInitial extends CurrencyState {
  final Decimal total;

  TokenInitial(List<Currency> tokens, {this.total}) : super(tokens);
}

class TokenLoaded extends CurrencyState {
  final List<Currency> tokens;
  final Decimal total;

  TokenLoaded(this.tokens, {this.total}) : super([], total: Decimal.zero);
}
