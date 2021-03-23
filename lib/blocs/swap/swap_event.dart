part of 'swap_bloc.dart';

abstract class SwapEvent extends Equatable {
  const SwapEvent();

  @override
  List<Object> get props => [];
}

class InitSwap extends SwapEvent {
  final Currency sellCurrency;
  // final int percentage;
  InitSwap(this.sellCurrency);
}

class ChangeSwapSellCurrency extends SwapEvent {
  final Currency sellCurrency;
  ChangeSwapSellCurrency(this.sellCurrency);
}

class ChangeSwapBuyCurrency extends SwapEvent {
  final Currency buyCurrency;
  ChangeSwapBuyCurrency(this.buyCurrency);
}

class ExchangeSwapCurrency extends SwapEvent {
  ExchangeSwapCurrency();
}

class UpdateSellAmount extends SwapEvent {
  final String amount;
  UpdateSellAmount(this.amount);
}

class UpdateBuyAmount extends SwapEvent {
  final String amount;
  UpdateBuyAmount(this.amount);
}

class CheckSwap extends SwapEvent {}

class SwapConfirmed extends SwapEvent {
  final String password;
  SwapConfirmed(this.password);
}

class ClearSwapResult extends SwapEvent {}
