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
        if (index > 0)
          this.add(UpdateTransactionCreateCurrency(msg.value[index]));
      }
    });
  }

  @override
  Stream<Transition<TransactionEvent, TransactionState>> transformEvents(
      Stream<TransactionEvent> events, transitionFn) {
    final nonDebounceStream = events
        .where((event) => event is! ValidAddress || event is! VerifyAmount);

    final debounceStream = events
        .where((event) => event is ValidAddress || event is VerifyAmount)
        .debounceTime(Duration(milliseconds: 1000));

    return super.transformEvents(
        MergeStream([nonDebounceStream, debounceStream]), transitionFn);
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
    if (event is VerifyAmount) {
      bool _rule2 = false;
      List<dynamic> result;
      List<bool> _rules = [_state.rules[0], _rule2];
      Decimal _fee;
      Decimal _gasPrice;
      Decimal _gasLimit;
      if (_state.rules[0] && event.amount.isNotEmpty) {
        // TODO TEST
        Log.debug('event is VerifyAmount: ${event.amount}');

        result = await _repo.getTransactionFee(
            amount: Decimal.parse(event.amount), address: _state.address);
        // TODO TEST
        Log.debug('getTransactionFee result: $result');
        if (result.length == 1) {
          _fee = result[0][TransactionPriority.standard];
          _rule2 = _repo.verifyAmount(Decimal.parse(event.amount), fee: _fee);
        } else if (result.length == 2) {
          _gasPrice = result[0][TransactionPriority.standard];
          _gasLimit = result[1];
          _fee = _gasPrice * _gasLimit;
          _rule2 = _repo.verifyAmount(Decimal.parse(event.amount), fee: _fee);
        }
        _rules = [_state.rules[0], _rule2];
        Log.debug(_rules);
        String _feeToFiat =
            _traderRepo.calculateFeeToFiat(_repo.currency, _fee).toString();
        yield _state.copyWith(
          amount: Decimal.parse(event.amount),
          rules: _rules,
          fee: _fee,
          feeToFiat: _feeToFiat,
          gasLimit: _gasLimit,
          gasPrice: _gasPrice,
        );
      } else {
        yield _state.copyWith(
          rules: _rules,
        );
      }
    }
    if (event is ChangePriority) {
      List<dynamic> result;
      bool _rule2 = true;
      Decimal _fee;
      if (_state.rules[0] && _state.rules[1]) {
        result = await _repo.getTransactionFee(
            amount: _state.amount, address: _state.address);
        if (result.length == 1) {
          _fee = result[0][event.priority];
          _gasPrice = null;
          _gasLimit = null;
          _rule2 = _repo.verifyAmount(_state.amount, fee: _fee);
        } else if (result.length == 2) {
          _gasPrice = result[0];
          _gasLimit = result[1];
          _fee = _gasPrice[event.priority] * _gasLimit;
          _rule2 = _repo.verifyAmount(_state.amount, fee: _fee);
        }
        String _feeToFiat =
            _traderRepo.calculateFeeToFiat(_repo.currency, _fee).toString();
        yield _state.copyWith(
            priority: event.priority,
            fee: _fee,
            feeToFiat: _feeToFiat,
            gasLimit: _gasLimit,
            gasPrice: _gasPrice[event.priority],
            rules: [_state.rules[0], _rule2]);
      }
    }
    if (event is InputGasLimit) {
      if (_state.gasPrice == null)
        yield _state.copyWith(gasLimit: Decimal.parse(event.gasLimit));
      bool _rule2 = true;
      Decimal _fee = Decimal.zero;
      if (_state.rules[0] && _state.rules[1]) {
        _fee = Decimal.parse(event.gasLimit) * _state.gasPrice;
        _rule2 = _repo.verifyAmount(_state.amount, fee: _fee);
        List<bool> _rules = [_state.rules[0], _rule2];
        String _feeToFiat =
            _traderRepo.calculateFeeToFiat(_repo.currency, _fee).toString();
        yield _state.copyWith(
            gasLimit: Decimal.parse(event.gasLimit),
            rules: _rules,
            feeToFiat: _feeToFiat);
      }
    }
    if (event is InputGasPrice) {
      if (_state.gasLimit == null)
        yield _state.copyWith(gasPrice: Decimal.parse(event.gasPrice));
      bool _rule2 = true;
      Decimal _fee = Decimal.zero;
      if (_state.rules[0] && _state.rules[1]) {
        _fee = _state.gasLimit * Decimal.parse(event.gasPrice);
        _rule2 = _repo.verifyAmount(_state.amount, fee: _fee);
        List<bool> _rules = [_state.rules[0], _rule2];
        String _feeToFiat =
            _traderRepo.calculateFeeToFiat(_repo.currency, _fee).toString();
        yield _state.copyWith(
            gasPrice: Decimal.parse(event.gasPrice),
            rules: _rules,
            feeToFiat: _feeToFiat);
      }
    }

    if (event is PublishTransaction) {
      yield TransactionPublishing();
      try {
        Log.debug('PublishTransaction _state: ${_state.props}}'); //--

        List result = await _repo.prepareTransaction(
            event.password, _state.address, _state.amount,
            fee: _state.fee,
            gasPrice: _state.gasPrice,
            gasLimit: _state.gasLimit);
        Log.debug('PublishTransaction result: $result'); //--

        bool success = await _repo.publishTransaction(result[0], result[1]);
        Log.warning('PublishTransaction success: $success'); //--
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
