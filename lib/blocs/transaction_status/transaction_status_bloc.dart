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
      if (msg.evt == ACCOUNT_EVT.OnUpdateAccount) {
        int index = msg.value.indexWhere((Account account) {
          return account.id == this._repo.account.id;
        });
        if (index < 0) return;
        Account account = msg.value[index];
        this.add(UpdateAccount(account));
      }
      if (msg.evt == ACCOUNT_EVT.OnUpdateTransactions) {
        Account account = msg.value['account'];
        if (account.id != this._repo.account.id) return;
        List<Transaction> transactions = msg.value['transactions'];
        this.add(UpdateTransactionList(account, transactions));
      }

      if (msg.evt == ACCOUNT_EVT.OnUpdateTransaction) {
        Account account = msg.value['account'];
        if (account.id != this._repo.account.id) return;
        Transaction transaction = msg.value['transaction'];
        this.add(UpdateTransaction(transaction));
      }
    });
  }

  @override
  Stream<TransactionStatusState> mapEventToState(
    TransactionStatusEvent event,
  ) async* {
    if (event is UpdateAccount) {
      if (state.account == null) {
        Log.debug('event.account: ${event.account}');
        _repo.setAccount(event.account);

        final List<Transaction> transactions = await _repo.getTransactions();
        Log.debug('transactions: $transactions');

        yield TransactionStatusLoaded(event.account, transactions, null);
      } else if (state.account!.symbol == event.account.symbol) {
        yield TransactionStatusLoaded(
            event.account, state.transactions, state.transaction);
      }
    }
    if (event is UpdateTransactionList) {
      if (state.account != null && state.account!.id == event.account.id) {
        if (state.transaction != null) {
          int index = event.transactions.indexWhere(
              (Transaction tx) => tx.txId == state.transaction!.txId);
          yield TransactionStatusLoaded(
              event.account, event.transactions, event.transactions[index]);
        }
        yield TransactionStatusLoaded(event.account, event.transactions, null);
      }
    }
    if (event is UpdateTransaction) {
      Log.debug('event.transaction: ${event.transaction}');
      yield TransactionStatusLoaded(
          state.account!, state.transactions, event.transaction);
    }
  }
}
