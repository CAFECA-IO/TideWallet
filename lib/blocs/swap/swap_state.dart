part of 'swap_bloc.dart';

enum SwapResult {
  none,
  insufficient,
  failure,
  success,
  zero,
  valid,
}

abstract class SwapState extends Equatable {
  const SwapState();

  @override
  List<Object> get props => [];
}

class SwapInitial extends SwapState {}

class SwapLoaded extends SwapState {
  final Currency sellCurrency;
  final Currency buyCurrency;
  final String sellAmount;
  final List<Currency> targets;
  final String fee;
  final int usePercent;
  final String buyAmount;
  final String exchangeRate;
  final SwapResult result;

  SwapLoaded(
      {this.sellCurrency,
      this.buyCurrency,
      this.sellAmount,
      this.fee,
      this.usePercent,
      this.targets,
      this.buyAmount,
      this.exchangeRate,
      this.result});

  SwapLoaded copyWith({
    Currency sellCurrency,
    Currency buyCurrency,
    String sellAmount,
    List<Currency> targets,
    String fee,
    int usePercent,
    String buyAmount,
    String exchangeRate,
    SwapResult result,
  }) {
    return SwapLoaded(
        sellCurrency: sellCurrency ?? this.sellCurrency,
        buyCurrency: buyCurrency ?? this.buyCurrency,
        sellAmount: sellAmount ?? this.sellAmount,
        fee: fee ?? this.fee,
        usePercent: usePercent ?? this.usePercent,
        targets: targets ?? this.targets,
        buyAmount: buyAmount ?? this.buyAmount,
        exchangeRate: exchangeRate ?? this.exchangeRate,
        result: result ?? this.result);
  }

  @override
  List<Object> get props => [
        sellCurrency,
        buyCurrency,
        sellAmount,
        fee,
        usePercent,
        targets,
        buyAmount,
        exchangeRate,
        result.toString()
      ];
}
