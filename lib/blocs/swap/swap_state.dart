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
  final String contract;
  final int usePercent;
  final String buyAmount;
  final String exchangeRate;
  final SwapResult result;
  final Decimal gasPrice;
  final Decimal gasLimit;

  SwapLoaded(
      {this.sellCurrency,
      this.buyCurrency,
      this.sellAmount,
      this.contract,
      this.usePercent,
      this.targets,
      this.buyAmount,
      this.exchangeRate,
      this.result,
      this.gasPrice,
      this.gasLimit});

  SwapLoaded copyWith(
      {Currency sellCurrency,
      Currency buyCurrency,
      String sellAmount,
      List<Currency> targets,
      String contract,
      int usePercent,
      String buyAmount,
      String exchangeRate,
      SwapResult result,
      Decimal gasPrice,
      Decimal gasLimit}) {
    return SwapLoaded(
        sellCurrency: sellCurrency ?? this.sellCurrency,
        buyCurrency: buyCurrency ?? this.buyCurrency,
        sellAmount: sellAmount ?? this.sellAmount,
        contract: contract ?? this.contract,
        usePercent: usePercent ?? this.usePercent,
        targets: targets ?? this.targets,
        buyAmount: buyAmount ?? this.buyAmount,
        exchangeRate: exchangeRate ?? this.exchangeRate,
        result: result ?? this.result,
        gasPrice: gasPrice ?? this.gasPrice,
        gasLimit: gasLimit ?? this.gasLimit);
  }

  @override
  List<Object> get props => [
        sellCurrency,
        buyCurrency,
        sellAmount,
        contract,
        usePercent,
        targets,
        buyAmount,
        exchangeRate,
        result.toString(),
        gasPrice,
        gasLimit
      ];
}
