import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/account.model.dart';
import '../../models/transaction.model.dart';
import '../../repositories/transaction_repository.dart';
import '../../repositories/trader_repository.dart';
import '../../helpers/logger.dart';

part 'transaction_status_event.dart';
part 'transaction_status_state.dart';

class TransactionStatusBloc
    extends Bloc<TransactionStatusEvent, TransactionStatusState> {
  TransactionRepository _repo;
  TraderRepository _traderRepo;
  StreamSubscription _subscription;

  TransactionStatusBloc(this._repo, this._traderRepo)
      : super(TransactionStatusInitial(null, [], null)) {
    _subscription?.cancel();
    this._repo.listener.listen((msg) {
      if (msg.evt == ACCOUNT_EVT.OnUpdateAccount) {
        Log.debug("msg.value ${(msg.value as Currency).name}");
        Currency currency = msg.value;

        this.add(UpdateCurrency(_addUSD(currency)));
      }
      if (msg.evt == ACCOUNT_EVT.OnUpdateTransactions) {
        Currency currency = msg.value['currency'];

        this.add(UpdateTransactionList(
            _addUSD(currency), msg.value['transactions']));
      }
    });
  }

  Currency _addUSD(Currency c) {
    return c.copyWith(inUSD: _traderRepo.calculateToFiat(c).toString());
  }

  @override
  Stream<TransactionStatusState> mapEventToState(
    TransactionStatusEvent event,
  ) async* {
    if (event is UpdateCurrency) {
      if (state.currency == null) {
        print('event.currency: ${event.currency}');
        _repo.setCurrency(event.currency);
        final List<Transaction> transactions = _repo.getTransactions() ?? [];
        yield TransactionStatusLoaded(event.currency, transactions, null);
      } else if (state.currency.symbol == event.currency.symbol) {
        yield TransactionStatusLoaded(
            event.currency, state.transactions, state.transaction);
      }
    }
    if (event is UpdateTransactionList) {
      if (state.currency != null &&
          state.currency.symbol == event.currency.symbol) {
        if (state.transaction != null) {
          int index = event.transactions.indexWhere(
              (Transaction tx) => tx.txId == state.transaction.txId);
          yield TransactionStatusLoaded(
              event.currency, event.transactions, event.transactions[index]);
        }
        yield TransactionStatusLoaded(event.currency, event.transactions, null);
      }
    }
    if (event is UpdateTransaction) {
      Log.debug('event.transaction: ${event.transaction}');
      yield TransactionStatusLoaded(
          state.currency, state.transactions, event.transaction);
    }
  }
}
