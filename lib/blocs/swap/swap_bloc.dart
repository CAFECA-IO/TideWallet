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
      Account sellAccount = event.sellAccount;
      List<Account> targets = AccountCore()
          .getAllAccounts()
          .where((curr) => curr.id != event.sellAccount.id)
          .toList();
      Account buyAccount = targets[0];
      Decimal usePercent = Decimal.fromInt(10);
      Decimal sellAmount = Decimal.tryParse(sellAccount.balance)! *
          usePercent /
          Decimal.fromInt(100);
      Map<String, dynamic> result = await _swapRepo.getSwapDetail(
          sellAccount, buyAccount,
          sellAmount: sellAmount.toString());
      String buyAmount = result['expectedExchangeAmount'];
      String exchangeRate = result['exchangeRate'];
      String contract = result['contract'];
      Decimal gasPrice = Decimal.tryParse(result['gasPrice'])!;
      Decimal gasLimit = Decimal.tryParse(result['gasLimit'])!;

      yield SwapLoaded(
          sellAccount: sellAccount,
          targets: targets,
          buyAccount: targets[0],
          contract: contract,
          exchangeRate: exchangeRate,
          sellAmount: sellAmount.toString(),
          buyAmount: buyAmount,
          gasPrice: gasPrice,
          gasLimit: gasLimit);
    }

    if (event is ChangeSwapSellAccount) {
      SwapLoaded _state = state as SwapLoaded;
      Account sellAccount = event.sellAccount;
      List<Account> targets = AccountCore()
          .getAllAccounts()
          .where((curr) => curr.id != event.sellAccount.id)
          .toList();
      Account buyAccount = _state.buyAccount!;
      if (event.sellAccount.id == buyAccount.id) buyAccount = targets[0];
      Decimal sellAmount = Decimal.tryParse(_state.sellAmount!)! <
                  Decimal.parse(sellAccount.balance) &&
              Decimal.tryParse(_state.sellAmount!)! != Decimal.zero
          ? Decimal.tryParse(_state.sellAmount!)!
          : Decimal.tryParse(sellAccount.balance)! *
              Decimal.fromInt(10) /
              Decimal.fromInt(100);
      Log.debug('sellAccount.amount: ${sellAccount.balance}');
      Log.debug('sellAmount: $sellAmount');
      Map<String, dynamic> result = await _swapRepo.getSwapDetail(
          sellAccount, buyAccount,
          sellAmount: sellAmount.toString());
      Decimal buyAmount = Decimal.tryParse(result['expectedExchangeAmount'])!;
      Decimal exchangeRate = Decimal.tryParse(result['exchangeRate'])!;
      String contract = result['contract'];
      Decimal gasPrice = Decimal.tryParse(result['gasPrice'])!;
      Decimal gasLimit = Decimal.tryParse(result['gasLimit'])!;

      yield _state.copyWith(
          sellAccount: sellAccount,
          buyAccount: buyAccount,
          sellAmount: sellAmount.toString(),
          contract: contract,
          targets: targets,
          exchangeRate: exchangeRate.toString(),
          buyAmount: buyAmount.toString(),
          gasPrice: gasPrice,
          gasLimit: gasLimit);
    }

    if (event is ChangeSwapBuyAccount) {
      SwapLoaded _state = state as SwapLoaded;
      Account buyAccount = event.buyAccount;
      Map<String, dynamic> result = await _swapRepo.getSwapDetail(
          _state.sellAccount!, buyAccount,
          sellAmount: _state.sellAmount);
      Decimal buyAmount = Decimal.tryParse(result['expectedExchangeAmount'])!;
      Decimal exchangeRate = Decimal.tryParse(result['exchangeRate'])!;
      String contract = result['contract'];
      Decimal gasPrice = Decimal.tryParse(result['gasPrice'])!;
      Decimal gasLimit = Decimal.tryParse(result['gasLimit'])!;
      yield _state.copyWith(
          buyAccount: buyAccount,
          exchangeRate: exchangeRate.toString(),
          buyAmount: buyAmount.toString(),
          contract: contract,
          gasPrice: gasPrice,
          gasLimit: gasLimit);
    }

    if (event is ExchangeSwapAccount) {
      SwapLoaded _state = state as SwapLoaded;
      Decimal sellAmount = Decimal.tryParse(_state.buyAccount!.balance)! *
          Decimal.fromInt(10) /
          Decimal.fromInt(100);
      Map<String, dynamic> result = await _swapRepo.getSwapDetail(
          _state.buyAccount!, _state.sellAccount!,
          sellAmount: sellAmount.toString());

      Decimal buyAmount = Decimal.tryParse(result['expectedExchangeAmount'])!;
      Decimal exchangeRate = Decimal.tryParse(result['exchangeRate'])!;
      String contract = result['contract'];
      Decimal gasPrice = Decimal.tryParse(result['gasPrice'])!;
      Decimal gasLimit = Decimal.tryParse(result['gasLimit'])!;

      List<Account> targets = AccountCore()
          .getAllAccounts()
          .where((curr) => curr.id != _state.buyAccount!.id)
          .toList();

      yield _state.copyWith(
          sellAccount: _state.buyAccount,
          buyAccount: _state.sellAccount,
          sellAmount: sellAmount.toString(),
          contract: contract,
          targets: targets,
          exchangeRate: exchangeRate.toString(),
          buyAmount: buyAmount.toString(),
          gasPrice: gasPrice,
          gasLimit: gasLimit);
    }

    if (event is UpdateSellAmount) {
      SwapLoaded _state = state as SwapLoaded;
      Decimal sellAmount = Decimal.tryParse(event.amount)!;
      Map<String, dynamic> result = await _swapRepo.getSwapDetail(
          _state.sellAccount!, _state.buyAccount!,
          sellAmount: sellAmount.toString());
      Decimal buyAmount = Decimal.tryParse(result['expectedExchangeAmount'])!;
      Decimal exchangeRate = Decimal.tryParse(result['exchangeRate'])!;
      Decimal gasPrice = Decimal.tryParse(result['gasPrice'])!;
      Decimal gasLimit = Decimal.tryParse(result['gasLimit'])!;
      yield _state.copyWith(
          sellAmount: sellAmount.toString(),
          buyAmount: buyAmount.toString(),
          exchangeRate: exchangeRate.toString(),
          gasPrice: gasPrice,
          gasLimit: gasLimit);
    }

    if (event is UpdateBuyAmount) {
      SwapLoaded _state = state as SwapLoaded;
      Decimal buyAmount = Decimal.tryParse(event.amount)!;

      if (buyAmount == Decimal.zero) return;
      Map<String, dynamic> result = await _swapRepo.getSwapDetail(
          _state.sellAccount!, _state.buyAccount!,
          buyAmount: buyAmount.toString());
      Decimal sellAmount = Decimal.tryParse(result['expectedExchangeAmount'])!;
      Decimal exchangeRate = Decimal.tryParse(result['exchangeRate'])!;
      Decimal gasPrice = Decimal.tryParse(result['gasPrice'])!;
      Decimal gasLimit = Decimal.tryParse(result['gasLimit'])!;

      yield _state.copyWith(
          sellAmount: sellAmount.toString(),
          buyAmount: buyAmount.toString(),
          exchangeRate: exchangeRate.toString(),
          gasPrice: gasPrice,
          gasLimit: gasLimit);
    }

    if (event is CheckSwap) {
      SwapLoaded _state = state as SwapLoaded;
      this.add(ClearSwapResult());

      if (Decimal.tryParse(_state.sellAmount!)! >
          Decimal.tryParse(_state.sellAccount!.balance)!) {
        yield _state.copyWith(result: SwapResult.insufficient);
        return;
      }

      if (Decimal.tryParse(_state.buyAmount!) == Decimal.zero) {
        yield _state.copyWith(result: SwapResult.zero);
        return;
      }

      yield _state.copyWith(result: SwapResult.valid);
    }

    if (event is SwapConfirmed) {
      SwapLoaded _state = state as SwapLoaded;
      // ++ error handle if buyAmoumt is too high need to update SwapUI => exchangeRate, and expected buyAmount 2021/3/19 Emily
      _transactionRepo.setAccount(_state.sellAccount!);

      // List result = await _swapRepo.swap(
      //   (await _transactionRepo.getPrivKey(event.password, 0, 0)),
      //   _state.sellAccount,
      //   _state.sellAmount,
      //   _state.buyAccount,
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
      SwapLoaded _state = state as SwapLoaded;
      yield _state.copyWith(result: SwapResult.none);
    }
  }
}
