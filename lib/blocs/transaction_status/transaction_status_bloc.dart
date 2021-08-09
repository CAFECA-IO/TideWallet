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
  late TransactionRepository _repo;
  late TraderRepository _traderRepo;
  late StreamSubscription? _subscription;

  TransactionStatusBloc(this._repo, this._traderRepo)
      : super(TransactionStatusInitial(null, [], null)) {
    _subscription?.cancel();
    this._repo.listener.listen((msg) {
      if (msg.evt == ACCOUNT_EVT.OnUpdateCurrency) {
        int index = msg.value.indexWhere((Currency currency) {
          return currency.id == this._repo.currency.id;
        });
        if (index < 0) return;
        Currency currency = msg.value[index];
        this.add(UpdateCurrency(_addUSD(currency)));
      }
      if (msg.evt == ACCOUNT_EVT.OnUpdateTransactions) {
        Currency currency = msg.value['currency'];
        if (currency.id != this._repo.currency.id) return;
        List<Transaction> transactions = msg.value['transactions'];
        this.add(UpdateTransactionList(_addUSD(currency), transactions));
      }

      if (msg.evt == ACCOUNT_EVT.OnUpdateTransaction) {
        Currency currency = msg.value['currency'];
        if (currency.id != this._repo.currency.id) return;
        Transaction transaction = msg.value['transaction'];
        this.add(UpdateTransaction(transaction));
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
        Log.debug('event.currency: ${event.currency}');
        _repo.setCurrency(event.currency);

        final List<Transaction> transactions = await _repo.getTransactions();
        Log.debug('transactions: $transactions');

        yield TransactionStatusLoaded(event.currency, transactions, null);
      } else if (state.currency!.symbol == event.currency.symbol) {
        yield TransactionStatusLoaded(
            event.currency, state.transactions, state.transaction);
      }
    }
    if (event is UpdateTransactionList) {
      if (state.currency != null && state.currency!.id == event.currency.id) {
        if (state.transaction != null) {
          int index = event.transactions.indexWhere(
              (Transaction tx) => tx.txId == state.transaction!.txId);
          yield TransactionStatusLoaded(
              event.currency, event.transactions, event.transactions[index]);
        }
        yield TransactionStatusLoaded(event.currency, event.transactions, null);
      }
    }
    if (event is UpdateTransaction) {
      Log.debug('event.transaction: ${event.transaction}');
      yield TransactionStatusLoaded(
          state.currency!, state.transactions, event.transaction);
    }
  }
}
