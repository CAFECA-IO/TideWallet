part of 'swap_bloc.dart';

abstract class SwapEvent extends Equatable {
  const SwapEvent();

  @override
  List<Object> get props => [];
}

class InitSwap extends SwapEvent {
  final Account sellAccount;
  // final int percentage;
  InitSwap(this.sellAccount);
}

class ChangeSwapSellAccount extends SwapEvent {
  final Account sellAccount;
  ChangeSwapSellAccount(this.sellAccount);
}

class ChangeSwapBuyAccount extends SwapEvent {
  final Account buyAccount;
  ChangeSwapBuyAccount(this.buyAccount);
}

class ExchangeSwapAccount extends SwapEvent {
  ExchangeSwapAccount();
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
