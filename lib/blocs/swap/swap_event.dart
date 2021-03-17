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

class UpdateUsePercent extends SwapEvent {
  final int percent;
  UpdateUsePercent(this.percent);
}

class UpdateBuyAmount extends SwapEvent {
  final String amount;
  UpdateBuyAmount(this.amount);
}

class CheckSwap extends SwapEvent {}

class SwapConfirmed extends SwapEvent {
  SwapConfirmed();
}

class ClearSwapResult extends SwapEvent {}
