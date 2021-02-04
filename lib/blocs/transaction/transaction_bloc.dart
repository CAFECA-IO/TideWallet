import 'dart:async';

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

  Map<TransactionPriority, String> _gasPrice;
  String _gasLimit;

  TransactionBloc(this._repo, this._traderRepo) : super(TransactionInitial());

  @override
  Stream<TransactionState> mapEventToState(
    TransactionEvent event,
  ) async* {
    if (event is UpdateTransactionCreateCurrency) {
      _repo.setCurrency(event.currency);
      yield TransactionInitial();
    }
    if (state is TransactionSent) return;
    if (state is TransactionPublishing) return;
    if (state is CreateTransactionFail) return;

    TransactionInitial _state = state;
    if (event is FetchTransactionFee) {
      // createRawTx
      String hex = 'asd'; //TODO
      List<dynamic> _fee = await _repo.getTransactionFee(hex);
      Decimal fee = _fee.length == 2
          ? _fee[0][_state.priority] * _fee[1]
          : _fee[0][_state.priority];
      Decimal feeToFiat = fee * Decimal.fromInt(68273);
      yield _state.copyWith(
        fee: fee.toString(),
        feeToFiat: feeToFiat.toString(),
        gasLimit: _fee.length == 2 ? _fee[1].toString() : '',
        gasPrice: _fee[0][_state.priority].toString(),
      );
    }
    if (event is ResetAddress) {
      List<bool> _rules = [false, _state.rules[1]];
      print(_rules);
      yield _state.copyWith(
        address: '',
        rules: _rules,
      );
    }
    if (event is ScanQRCode) {
      Log.debug("ValidAddress address: ${event.address}");
      bool verifiedAddress = await _repo.verifyAddress(
          event.address, false); // TODO Account add publish property
      List<bool> _rules = [verifiedAddress, _state.rules[1]];
      Log.debug(_rules);
      yield _state.copyWith(
        address: event.address,
        rules: _rules,
      );
    }
    if (event is ValidAddress) {
      Log.debug("ValidAddress address: ${event.address}");
      bool verifiedAddress = await _repo.verifyAddress(event.address, false);
      List<bool> _rules = [verifiedAddress, _state.rules[1]];
      Log.debug(_rules);
      yield _state.copyWith(
        address: event.address,
        rules: _rules,
      );
    }
    if (event is ValidAmount) {
      List<bool> _rules = [
        _state.rules[0],
        _repo.validAmount(event.amount, priority: TransactionPriority.standard)
      ];
      Log.debug(_rules);
      yield _state.copyWith(
        amount: event.amount,
        rules: _rules,
      );
    }
    if (event is ChangePriority) {
      // TODO getTransactionFee
      List<bool> _rules = [
        _state.rules[0],
        _repo.validAmount(_state.amount, priority: event.priority)
      ];
      Decimal fee = Decimal.parse(_gasPrice[event.priority]) *
          Decimal.parse(_gasLimit) /
          Decimal.fromInt(BigInt.from(10).pow(9).toInt());
      Decimal feeToFiat = fee * Decimal.fromInt(68273);
      yield _state.copyWith(
        priority: event.priority,
        fee: '$fee',
        feeToFiat: '$feeToFiat',
        gasLimit: _gasLimit,
        gasPrice: _gasPrice[event.priority],
        rules: _rules,
      );
    }
    if (event is InputGasLimit) {
      if (_state.gasPrice.isEmpty)
        yield _state.copyWith(gasLimit: event.gasLimit);
      List<bool> _rules = [
        _state.rules[0],
        _repo.validAmount(_state.amount,
            gasLimit: event.gasLimit, gasPrice: _state.gasPrice)
      ];
      yield _state.copyWith(
        gasLimit: event.gasLimit,
        rules: _rules,
      );
    }
    if (event is InputGasPrice) {
      if (_state.gasLimit.isEmpty)
        yield _state.copyWith(gasLimit: event.gasPrice);
      List<bool> _rules = [
        _state.rules[0],
        _repo.validAmount(_state.amount,
            gasLimit: _state.gasLimit, gasPrice: event.gasPrice)
      ];
      yield _state.copyWith(
        gasLimit: event.gasPrice,
        rules: _rules,
      );
    }

    if (event is CreateTransaction) {
      yield TransactionPublishing();
      bool result = await _repo.createTransaction(_state.props);
      if (result) {
        yield TransactionSent();
      } else {
        yield CreateTransactionFail();
      }
    }
  }
}
