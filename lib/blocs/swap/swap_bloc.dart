import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

import '../../cores/account.dart';
import '../../models/account.model.dart';
import '../../repositories/swap_repository.dart';
import '../../repositories/transaction_repository.dart';

import '../../helpers/logger.dart'; // --

part 'swap_event.dart';
part 'swap_state.dart';

class SwapBloc extends Bloc<SwapEvent, SwapState> {
  SwapRepository _swapRepo;
  TransactionRepository _transactionRepo;
  SwapBloc(this._swapRepo, this._transactionRepo) : super(SwapInitial());

  @override
  Stream<Transition<SwapEvent, SwapState>> transformEvents(
      Stream<SwapEvent> events, transitionFn) {
    final nonDebounceStream = events.where(
        (event) => event is! UpdateBuyAmount && event is! UpdateSellAmount);

    final debounceStream = events
        .where((event) => event is UpdateBuyAmount || event is UpdateSellAmount)
        .debounceTime(Duration(milliseconds: 1000));

    return super.transformEvents(
        MergeStream([nonDebounceStream, debounceStream]), transitionFn);
  }

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
      Decimal usePercent = Decimal.fromInt(10);
      Decimal sellAmount = Decimal.tryParse(sellCurrency.amount) *
          usePercent /
          Decimal.fromInt(100);
      Map<String, String> result = await _swapRepo.getSwapDetail(
          sellCurrency, buyCurrency,
          sellAmount: sellAmount.toString());
      String buyAmount = result['expectedExchangeAmount'];
      String exchangeRate = result['exchangeRate'];
      String contract = result['contract'];
      Decimal gasPrice = Decimal.tryParse(result['gasPrice']);
      Decimal gasLimit = Decimal.tryParse(result['gasLimit']);

      yield SwapLoaded(
          sellCurrency: sellCurrency,
          targets: targets,
          buyCurrency: targets[0],
          contract: contract,
          exchangeRate: exchangeRate,
          sellAmount: sellAmount.toString(),
          buyAmount: buyAmount,
          gasPrice: gasPrice,
          gasLimit: gasLimit);
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
      Decimal sellAmount = Decimal.tryParse(_state.sellAmount) <
                  Decimal.parse(sellCurrency.amount) &&
              Decimal.tryParse(_state.sellAmount) != Decimal.zero
          ? Decimal.tryParse(_state.sellAmount)
          : Decimal.tryParse(sellCurrency.amount) *
              Decimal.fromInt(10) /
              Decimal.fromInt(100);
      Log.debug('sellCurrency.amount: ${sellCurrency.amount}');
      Log.debug('sellAmount: $sellAmount');
      Map<String, String> result = await _swapRepo.getSwapDetail(
          sellCurrency, buyCurrency,
          sellAmount: sellAmount.toString());
      Decimal buyAmount = Decimal.tryParse(result['expectedExchangeAmount']);
      Decimal exchangeRate = Decimal.tryParse(result['exchangeRate']);
      String contract = result['contract'];
      Decimal gasPrice = Decimal.tryParse(result['gasPrice']);
      Decimal gasLimit = Decimal.tryParse(result['gasLimit']);

      yield _state.copyWith(
          sellCurrency: sellCurrency,
          buyCurrency: buyCurrency,
          sellAmount: sellAmount.toString(),
          contract: contract,
          targets: targets,
          exchangeRate: exchangeRate.toString(),
          buyAmount: buyAmount.toString(),
          gasPrice: gasPrice,
          gasLimit: gasLimit);
    }

    if (event is ChangeSwapBuyCurrency) {
      SwapLoaded _state = state;
      Currency buyCurrency = event.buyCurrency;
      Map<String, String> result = await _swapRepo.getSwapDetail(
          _state.sellCurrency, buyCurrency,
          sellAmount: _state.sellAmount);
      Decimal buyAmount = Decimal.tryParse(result['expectedExchangeAmount']);
      Decimal exchangeRate = Decimal.tryParse(result['exchangeRate']);
      String contract = result['contract'];
      Decimal gasPrice = Decimal.tryParse(result['gasPrice']);
      Decimal gasLimit = Decimal.tryParse(result['gasLimit']);
      yield _state.copyWith(
          buyCurrency: buyCurrency,
          exchangeRate: exchangeRate.toString(),
          buyAmount: buyAmount.toString(),
          contract: contract,
          gasPrice: gasPrice,
          gasLimit: gasLimit);
    }

    if (event is ExchangeSwapCurrency) {
      SwapLoaded _state = state;
      Decimal sellAmount = Decimal.tryParse(_state.buyCurrency.amount) *
          Decimal.fromInt(10) /
          Decimal.fromInt(100);
      Map<String, String> result = await _swapRepo.getSwapDetail(
          _state.buyCurrency, _state.sellCurrency,
          sellAmount: sellAmount.toString());

      Decimal buyAmount = Decimal.tryParse(result['expectedExchangeAmount']);
      Decimal exchangeRate = Decimal.tryParse(result['exchangeRate']);
      String contract = result['contract'];
      Decimal gasPrice = Decimal.tryParse(result['gasPrice']);
      Decimal gasLimit = Decimal.tryParse(result['gasLimit']);

      List<Currency> targets = AccountCore()
          .getAllCurrencies()
          .where((curr) => curr.id != _state.buyCurrency.id)
          .toList();

      yield _state.copyWith(
          sellCurrency: _state.buyCurrency,
          buyCurrency: _state.sellCurrency,
          sellAmount: sellAmount.toString(),
          contract: contract,
          targets: targets,
          exchangeRate: exchangeRate.toString(),
          buyAmount: buyAmount.toString(),
          gasPrice: gasPrice,
          gasLimit: gasLimit);
    }

    if (event is UpdateSellAmount) {
      SwapLoaded _state = state;
      Decimal sellAmount = Decimal.tryParse(event.amount);
      Map<String, String> result = await _swapRepo.getSwapDetail(
          _state.sellCurrency, _state.buyCurrency,
          sellAmount: sellAmount.toString());
      Decimal buyAmount = Decimal.tryParse(result['expectedExchangeAmount']);
      Decimal exchangeRate = Decimal.tryParse(result['exchangeRate']);
      Decimal gasPrice = Decimal.tryParse(result['gasPrice']);
      Decimal gasLimit = Decimal.tryParse(result['gasLimit']);
      yield _state.copyWith(
          sellAmount: sellAmount.toString(),
          buyAmount: buyAmount.toString(),
          exchangeRate: exchangeRate.toString(),
          gasPrice: gasPrice,
          gasLimit: gasLimit);
    }

    if (event is UpdateBuyAmount) {
      SwapLoaded _state = state;
      Decimal buyAmount = Decimal.tryParse(event.amount);

      if (buyAmount == null || buyAmount == Decimal.zero) return;
      Map<String, String> result = await _swapRepo.getSwapDetail(
          _state.sellCurrency, _state.buyCurrency,
          buyAmount: buyAmount.toString());
      Decimal sellAmount = Decimal.tryParse(result['expectedExchangeAmount']);
      Decimal exchangeRate = Decimal.tryParse(result['exchangeRate']);
      Decimal gasPrice = Decimal.tryParse(result['gasPrice']);
      Decimal gasLimit = Decimal.tryParse(result['gasLimit']);

      yield _state.copyWith(
          sellAmount: sellAmount.toString(),
          buyAmount: buyAmount.toString(),
          exchangeRate: exchangeRate.toString(),
          gasPrice: gasPrice,
          gasLimit: gasLimit);
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
      // ++ error handle if buyAmoumt is too high need to update SwapUI => exchangeRate, and expected buyAmount 2021/3/19 Emily
      _transactionRepo.setCurrency(_state.sellCurrency);

      // List result = await _swapRepo.swap(
      //   (await _transactionRepo.getPrivKey(event.password, 0, 0)),
      //   _state.sellCurrency,
      //   _state.sellAmount,
      //   _state.buyCurrency,
      //   _state.buyAmount,
      //   _state.contract,
      //   _state.gasPrice,
      //   _state.gasLimit,
      // );

      // final publishResult = await _transactionRepo.publishTransaction(
      //     result[0], result[1],
      //     blockchainId: ''); // ++ will use cfc token 2021/3/19 Emily

      // if (publishResult[0])
      if (true)
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
