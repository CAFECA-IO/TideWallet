import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/account.model.dart';
import '../../models/transaction.model.dart';
import '../../repositories/transaction_repository.dart';

import '../../helpers/logger.dart';

part 'account_detail_event.dart';
part 'account_detail_state.dart';

class AccountDetailBloc extends Bloc<AccountDetailEvent, AccountDetailState> {
  late TransactionRepository _repo;

  AccountDetailBloc(this._repo) : super(AccountDetailInitial()) {
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
        this.add(UpdateTransaction(account, transaction));
      }
    });
  }

  @override
  Stream<AccountDetailState> mapEventToState(
    AccountDetailEvent event,
  ) async* {
    if (event is GetAccountDetail) {
      final Map accountDetail = await _repo.getAccountDetail(event.accountId);
      Account account = accountDetail["account"];
      List<Transaction> transactions = accountDetail["transactions"];
      Account shareAccount = accountDetail["shareAccount"];

      yield AccountDetailLoaded(account, shareAccount, transactions);
    }
    if (event is UpdateAccount) {
      Log.debug('event.account: ${event.account}');
      if (state.account!.symbol == event.account.symbol) {
        if (state is AccountDetailLoaded) {
          AccountDetailLoaded _state = state as AccountDetailLoaded;
          yield AccountDetailLoaded(
              event.account, _state.shareAccount, _state.transactions);
        } else if (state is TransactionLoaded) {
          TransactionLoaded _state = state as TransactionLoaded;
          yield TransactionLoaded(
              event.account, _state.shareAccount, _state.transaction);
        }
      }
    }
    if (event is UpdateTransactionList) {
      if (state.account != null && state.account!.id == event.account.id) {
        yield AccountDetailLoaded(
            event.account, state.shareAccount!, event.transactions);
      }
    }
    if (event is GetTransactionDetial) {
      Map transactionDetail =
          await this._repo.getTransactionDetail(event.accountId, event.txid);
      Account account = transactionDetail["account"];
      Account shareAccount = transactionDetail["shareAccount"];
      Transaction transaction = transactionDetail["transaction"];
      yield TransactionLoaded(account, shareAccount, transaction);
    }
    if (event is UpdateTransaction) {
      if (state.account != null &&
          state.account!.id == event.account.id &&
          event.transaction.txId == _repo.transaction.txId) {
        Log.debug('event.transaction: ${event.transaction}');
        if (state is AccountDetailLoaded) {
          AccountDetailLoaded _state = state as AccountDetailLoaded;
          int index = _state.transactions.indexWhere(
              (Transaction tx) => tx.txId == event.transaction.txId);
          List<Transaction> transactions = [..._state.transactions];
          transactions[index] = event.transaction;
          yield AccountDetailLoaded(
              _state.account, _state.shareAccount, transactions);
        } else if (state is TransactionLoaded) {
          TransactionLoaded _state = state as TransactionLoaded;
          yield TransactionLoaded(
              event.account, _state.shareAccount, event.transaction);
        }
      }
    }
  }
}
