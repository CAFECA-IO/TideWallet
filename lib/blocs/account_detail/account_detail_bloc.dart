import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/account.model.dart';
import '../../models/transaction.model.dart';
import '../../repositories/account_repository.dart';

import '../../helpers/logger.dart';

part 'account_detail_event.dart';
part 'account_detail_state.dart';

class AccountDetailBloc extends Bloc<AccountDetailEvent, AccountDetailState> {
  AccountRepository _repo;

  AccountDetailBloc(this._repo) : super(AccountDetailInitial()) {
    this._repo.listener.listen((msg) {
      if (msg.evt == ACCOUNT_EVT.OnUpdateAccount) {
        List<Account> accounts = msg.value["accounts"];
        int index = accounts.indexWhere((Account account) {
          return account.id == state.account!.id;
        });
        if (index < 0) return;
        Account account = accounts[index];
        this.add(UpdateAccount(account));
      }
      if (msg.evt == ACCOUNT_EVT.OnUpdateTransactions) {
        Account account = msg.value['account'];
        if (account.id != this.state.account!.id) return;
        List<Transaction> transactions = msg.value['transactions'];
        this.add(UpdateTransactionList(account, transactions));
      }

      if (msg.evt == ACCOUNT_EVT.OnUpdateTransaction) {
        Account account = msg.value['account'];
        if (account.id != this.state.account!.id) return;
        Transaction transaction = msg.value['transaction'];
        this.add(UpdateTransaction(account, transaction));
      }
    });
  }

  @override
  Stream<AccountDetailState> mapEventToState(
    AccountDetailEvent event,
  ) async* {
    if (state is AccountDetailInitial) {
      if (event is GetAccountDetail) {
        final Map accountDetail = await _repo.getAccountDetail(event.accountId);
        Account account = accountDetail["account"];
        List<Transaction> transactions = accountDetail["transactions"];
        Account shareAccount = accountDetail["shareAccount"];

        yield AccountDetailLoaded(account, shareAccount, transactions);
      }
    }
    if (state is AccountDetailLoaded) {
      AccountDetailLoaded _state = state as AccountDetailLoaded;
      if (event is UpdateAccount) {
        Log.debug('event.account: ${event.account}');
        if (_state.account.symbol == event.account.symbol) {
          yield AccountDetailLoaded(
              event.account, _state.shareAccount, _state.transactions);
        }
      }
      if (event is UpdateTransactionList) {
        if (_state.account.id == event.account.id) {
          yield AccountDetailLoaded(
              event.account, _state.shareAccount, event.transactions);
        }
      }
      if (event is UpdateTransaction) {
        Log.debug('event.transaction: ${event.transaction}');
        int index = _state.transactions
            .indexWhere((Transaction tx) => tx.txId == event.transaction.txId);
        List<Transaction> transactions = [..._state.transactions];
        transactions[index] = event.transaction;
        yield AccountDetailLoaded(
            event.account, _state.shareAccount, transactions);
      }
    }
  }
}
