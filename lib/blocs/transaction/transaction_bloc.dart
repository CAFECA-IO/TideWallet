import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:decimal/decimal.dart';

import '../../repositories/transaction_repository.dart';
import '../../helpers/logger.dart';
import '../../repositories/trader_repository.dart';
import '../../models/transaction.model.dart';
import '../../models/account.model.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionRepository _repo;
  TraderRepository _traderRepo;

  StreamSubscription _subscription;

  Map<TransactionPriority, Decimal> _gasPrice;
  Decimal _gasLimit;

  TransactionBloc(this._repo, this._traderRepo) : super(TransactionInitial()) {
    _subscription?.cancel();
    this._repo.listener.listen((msg) {
      if (msg.evt == ACCOUNT_EVT.OnUpdateCurrency) {
        int index = msg.value.indexWhere((Currency currency) =>
            currency.accountType == this._repo.currency.accountType);
        if (index > 0) {
          Currency currency = msg.value[index];
          this.add(UpdateTransactionCreateCurrency(currency));
        }
      }
    });
  }

  @override
  Stream<Transition<TransactionEvent, TransactionState>> transformEvents(
      Stream<TransactionEvent> events, transitionFn) {
    final nonDebounceStream = events.where((event) =>
        event is! ValidAddress &&
        event is! VerifyAmount &&
        event is! InputGasPrice &&
        event is! InputGasLimit);

    final debounceStream = events
        .where((event) =>
            event is VerifyAmount ||
            event is InputGasPrice ||
            event is InputGasLimit)
        .debounceTime(Duration(milliseconds: 1000));

    final debounceAddressStream = events.where((event) => event is ValidAddress).debounceTime(Duration(milliseconds: 1000));

    return super.transformEvents(
        MergeStream([nonDebounceStream, debounceStream, debounceAddressStream]), transitionFn);
  }

  @override
  Stream<TransactionState> mapEventToState(
    TransactionEvent event,
  ) async* {
    if (event is UpdateTransactionCreateCurrency) {
      _repo.setCurrency(event.currency);
      if (state is TransactionInitial) {
        TransactionInitial _state = state;
        yield _state.copyWith(spandable: Decimal.parse(event.currency.amount));
      } else {
        yield TransactionInitial(
            spandable: Decimal.parse(event.currency.amount));
      }
    }
    if (state is TransactionSent) return;
    if (state is TransactionPublishing) return;
    if (state is CreateTransactionFail) return;

    TransactionInitial _state = state;

    if (event is ResetAddress) {
      List<bool> _rules = [false, _state.rules[1]];
      yield _state.copyWith(
        address: '',
        rules: _rules,
      );
    }
    if (event is ScanQRCode) {
      bool verifiedAddress = await _repo
          .verifyAddress(event.address); // TODO Account add publish property
      List<bool> _rules = [verifiedAddress, _state.rules[1]];
      Log.debug(_rules);
      yield _state.copyWith(
        address: event.address,
        rules: _rules,
      );
    }
    if (event is ValidAddress) {
      bool verifiedAddress = await _repo.verifyAddress(event.address);
      List<bool> _rules = [verifiedAddress, _state.rules[1]];
      Log.debug(_rules);
      yield _state.copyWith(
        address: event.address,
        rules: _rules,
      );
    }
    if (event is VerifyAmount) {

      
      bool rule2 = false;
      List<dynamic> result;
      List<bool> rules = [_state.rules[0], rule2];
      Decimal fee;
      Decimal gasPrice;
      Decimal gasLimit;
      Decimal amount;
      String feeToFiat;
      String message;

      amount = Decimal.tryParse(event.amount);
      if (_state.rules[0] && amount != null) {
        result = await _repo.getTransactionFee(
           amount: amount, address: _state.address);
        if (result.length == 1) {
          _gasPrice = result[0];
          fee = _gasPrice[TransactionPriority.standard];
          gasLimit = null;
          gasPrice = null;
          rule2 = _repo.verifyAmount(amount, fee: fee);
        } else {
          _gasPrice = result[0];
          gasPrice = result[0][TransactionPriority.standard];
          gasLimit = result[1];
          try {
            message = result[2];
          } catch (e) {}
          if (gasLimit != null) {
            fee = gasPrice * gasLimit;
            rule2 = _repo.verifyAmount(amount, fee: fee);
          } else {
            rule2 = false;
          }
        }
        rules = [_state.rules[0], rule2];
        Log.debug(rules);
        if (gasLimit != null)
          feeToFiat =
              _traderRepo.calculateAmountToFiat(_repo.currency, fee).toString();
        yield _state.copyWith(
          amount: amount,
          rules: rules,
          fee: fee,
          feeToFiat: feeToFiat,
          gasLimit: gasLimit,
          gasPrice: gasPrice,
          message: message,
        );
      } else {
        yield _state.copyWith(
          rules: rules,
        );
      }
    }
    if (event is ChangePriority) {
      List<dynamic> result;
      bool rule2 = true;
      Decimal fee;
      Decimal gasPrice;
      Decimal gasLimit;
      String message;
      if (_state.rules[0] && _state.rules[1]) {
        result = await _repo.getTransactionFee(
            amount: _state.amount, address: _state.address);
        if (result.length == 1) {
          _gasPrice = result[0];
          gasLimit = null;
          gasPrice = null;
          fee = _gasPrice[event.priority];
          rule2 = _repo.verifyAmount(_state.amount, fee: fee);
        } else {
          _gasPrice = result[0];
          gasPrice = result[0][event.priority];
          gasLimit = result[1];
          fee = gasPrice * gasLimit;
          rule2 = _repo.verifyAmount(_state.amount, fee: fee);
          try {
            message = result[2];
          } catch (e) {}
        }
        String feeToFiat =
            _traderRepo.calculateAmountToFiat(_repo.currency, fee).toString();
        yield _state.copyWith(
            priority: event.priority,
            fee: fee,
            feeToFiat: feeToFiat,
            gasLimit: gasLimit,
            gasPrice: gasPrice,
            message: message,
            rules: [_state.rules[0], rule2]);
      }
    }
    if (event is InputGasLimit) {
      if (_state.gasPrice == null)
        yield _state.copyWith(gasLimit: Decimal.parse(event.gasLimit));
      bool rule2 = true;
      Decimal fee = Decimal.zero;
      if (_state.rules[0] && _state.rules[1]) {
        fee = Decimal.parse(event.gasLimit) * _state.gasPrice;
        rule2 = _repo.verifyAmount(_state.amount, fee: fee);
        List<bool> rules = [_state.rules[0], rule2];
        String feeToFiat =
            _traderRepo.calculateAmountToFiat(_repo.currency, fee).toString();
        yield _state.copyWith(
            gasLimit: Decimal.parse(event.gasLimit),
            rules: rules,
            feeToFiat: feeToFiat);
      }
    }
    if (event is InputGasPrice) {
      if (_state.gasLimit == null)
        yield _state.copyWith(gasPrice: Decimal.parse(event.gasPrice));
      bool rule2 = true;
      Decimal fee = Decimal.zero;
      if (_state.rules[0] && _state.rules[1]) {
        fee = _state.gasLimit * Decimal.parse(event.gasPrice);
        rule2 = _repo.verifyAmount(_state.amount, fee: fee);
        List<bool> rules = [_state.rules[0], rule2];
        String feeToFiat =
            _traderRepo.calculateAmountToFiat(_repo.currency, fee).toString();
        yield _state.copyWith(
            gasPrice: Decimal.parse(event.gasPrice),
            rules: rules,
            feeToFiat: feeToFiat);
      }
    }

    if (event is PublishTransaction) {
      yield TransactionPublishing();
      try {
        List result = await _repo.prepareTransaction(
            event.password, _state.address, _state.amount,
            fee: _state.fee,
            gasPrice: _state.gasPrice,
            gasLimit: _state.gasLimit,
            message: _state.message);
        final publishResult =
            await _repo.publishTransaction(result[0], result[1]);
        bool success = publishResult[0];
        if (success)
          yield TransactionSent();
        else
          yield CreateTransactionFail();
      } catch (e) {
        yield CreateTransactionFail();
      }
    }
  }
}
