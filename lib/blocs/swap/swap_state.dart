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
  final Account? sellAccount;
  final Account? buyAccount;
  final String? sellAmount;
  final List<Account>? targets;
  final String? contract;
  final String? buyAmount;
  final String? exchangeRate;
  final SwapResult? result;
  final Decimal? gasPrice;
  final Decimal? gasLimit;

  SwapLoaded(
      {this.sellAccount,
      this.buyAccount,
      this.sellAmount,
      this.contract,
      this.targets,
      this.buyAmount,
      this.exchangeRate,
      this.result,
      this.gasPrice,
      this.gasLimit});

  SwapLoaded copyWith(
      {Account? sellAccount,
      Account? buyAccount,
      String? sellAmount,
      List<Account>? targets,
      String? contract,
      String? buyAmount,
      String? exchangeRate,
      SwapResult? result,
      Decimal? gasPrice,
      Decimal? gasLimit}) {
    return SwapLoaded(
        sellAccount: sellAccount ?? this.sellAccount,
        buyAccount: buyAccount ?? this.buyAccount,
        sellAmount: sellAmount ?? this.sellAmount,
        contract: contract ?? this.contract,
        targets: targets ?? this.targets,
        buyAmount: buyAmount ?? this.buyAmount,
        exchangeRate: exchangeRate ?? this.exchangeRate,
        result: result ?? this.result,
        gasPrice: gasPrice ?? this.gasPrice,
        gasLimit: gasLimit ?? this.gasLimit);
  }

  @override
  List<Object> get props => [
        sellAccount!,
        buyAccount!,
        sellAmount!,
        contract!,
        targets!,
        buyAmount!,
        exchangeRate!,
        result.toString(),
        gasPrice!,
        gasLimit!
      ];
}
