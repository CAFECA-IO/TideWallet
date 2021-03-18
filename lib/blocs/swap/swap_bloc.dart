import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:tidewallet3/cores/account.dart';
import 'package:tidewallet3/helpers/logger.dart';

import '../../cores/account.dart';
import '../../models/account.model.dart';
import '../../repositories/swap_repository.dart';
import '../../repositories/trader_repository.dart';

part 'swap_event.dart';
part 'swap_state.dart';

class SwapBloc extends Bloc<SwapEvent, SwapState> {
  SwapRepository _swapRepo;
  TraderRepository _traderRepo;
  SwapBloc(this._swapRepo, this._traderRepo) : super(SwapInitial());

  @override
  Stream<SwapState> mapEventToState(
    SwapEvent event,
  ) async* {
    if (event is InitSwap) {
      Currency sellCurrency = event.sellCurrency;
      List<Currency> targets = AccountCore()
          .getAllCurrencies()
          .where((curr) => curr.id != event.sellCurrency.id)
          .toList();
      Currency buyCurrency = targets[0];
      Decimal usePercent = Decimal.fromInt(1);
      Decimal sellAmount = Decimal.tryParse(sellCurrency.amount) *
          usePercent /
          Decimal.fromInt(100);
      Log.debug(
          'sellAmount[runtimeType: ${sellAmount.runtimeType}]: $sellAmount');
      Map<String, Decimal> result = _traderRepo.getSwapRateAndAmount(
          sellCurrency, buyCurrency, sellAmount);
      Decimal buyAmount = result['buyAmount'];
      Decimal exchangeRate = result['exchangeRate'];

      Decimal fee; //= _swapRepo
      //     .getTransactionFee(); //++ get transaction fee 2021/3/17 Emily

      yield SwapLoaded(
        sellCurrency: sellCurrency,
        targets: targets,
        buyCurrency: targets[0],
        fee: fee.toString(),
        usePercent: usePercent.toInt(),
        exchangeRate: exchangeRate.toString(),
        sellAmount: sellAmount.toString(),
        buyAmount: buyAmount.toString(),
      );
    }

    if (event is ChangeSwapSellCurrency) {
      SwapLoaded _state = state;
      Currency sellCurrency = event.sellCurrency;
      List<Currency> targets = AccountCore()
          .getAllCurrencies()
          .where((curr) => curr.id != event.sellCurrency.id)
          .toList();
      Currency buyCurrency = _state.buyCurrency;
      if (event.sellCurrency.id == buyCurrency.id) buyCurrency = targets[0];
      Decimal sellAmount = Decimal.tryParse(sellCurrency.amount) *
          Decimal.fromInt(_state.usePercent) /
          Decimal.fromInt(100);
      Map<String, Decimal> result = _traderRepo.getSwapRateAndAmount(
          sellCurrency, buyCurrency, sellAmount);
      Decimal buyAmount = result['buyAmount'];
      Decimal exchangeRate = result['exchangeRate'];
      yield _state.copyWith(
          sellCurrency: sellCurrency,
          buyCurrency: buyCurrency,
          sellAmount: sellAmount.toString(),
          targets: targets,
          exchangeRate: exchangeRate.toString(),
          buyAmount: buyAmount.toString());
    }

    if (event is ChangeSwapBuyCurrency) {
      SwapLoaded _state = state;
      Currency buyCurrency = event.buyCurrency;
      Map<String, Decimal> result = _traderRepo.getSwapRateAndAmount(
          _state.sellCurrency,
          buyCurrency,
          Decimal.tryParse(_state.sellAmount));
      Decimal buyAmount = result['buyAmount'];
      Decimal exchangeRate = result['exchangeRate'];
      yield _state.copyWith(
          buyCurrency: buyCurrency,
          exchangeRate: exchangeRate.toString(),
          buyAmount: buyAmount.toString());
    }

    if (event is UpdateUsePercent) {
      SwapLoaded _state = state;
      Decimal percent = Decimal.fromInt(event.percent);
      Decimal sellAmount = Decimal.tryParse(_state.sellCurrency.amount) *
          percent /
          Decimal.fromInt(100);
      Map<String, Decimal> result = _traderRepo.getSwapRateAndAmount(
          _state.sellCurrency, _state.buyCurrency, sellAmount);
      Decimal buyAmount = result['buyAmount'];
      // Decimal exchangeRate = result['exchangeRate'];

      yield _state.copyWith(
        usePercent: event.percent,
        sellAmount: sellAmount.toString(),
        buyAmount: buyAmount.toString(),
      );
    }

    if (event is UpdateBuyAmount) {
      SwapLoaded _state = state;
      Decimal buyAmount = Decimal.tryParse(event.amount);
      // ++ add debounce && check function 2021/03/17 Emily
      if (buyAmount == null || buyAmount == Decimal.zero) return;
      Decimal usePercent = buyAmount /
          Decimal.tryParse(_state.exchangeRate) /
          Decimal.tryParse(_state.sellCurrency.amount) *
          Decimal.fromInt(100);
      Decimal sellAmount = Decimal.tryParse(_state.sellCurrency.amount) *
          usePercent /
          Decimal.fromInt(100);

      if (usePercent > Decimal.fromInt(100)) usePercent = Decimal.fromInt(100);

      yield _state.copyWith(
          usePercent: usePercent.toInt(),
          sellAmount: sellAmount.toString(),
          buyAmount: buyAmount.toString());
    }

    if (event is CheckSwap) {
      SwapLoaded _state = state;
      this.add(ClearSwapResult());

      if (Decimal.tryParse(_state.sellAmount) >
          Decimal.tryParse(_state.sellCurrency.amount)) {
        yield _state.copyWith(result: SwapResult.insufficient);
        return;
      }

      if (Decimal.tryParse(_state.buyAmount) == Decimal.zero) {
        yield _state.copyWith(result: SwapResult.zero);
        return;
      }

      yield _state.copyWith(result: SwapResult.valid);
    }

    if (event is SwapConfirmed) {
      SwapLoaded _state = state;

      List result = [
        true
      ]; // ++ swapRepo call ContractCore().swap 2021/3/17 Emily
      if (result[0])
        yield _state.copyWith(result: SwapResult.success);
      else
        yield _state.copyWith(result: SwapResult.none);
    }

    if (event is ClearSwapResult) {
      SwapLoaded _state = state;
      yield _state.copyWith(result: SwapResult.none);
    }
  }
}
