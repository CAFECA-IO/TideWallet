import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import '../../repositories/account_repository.dart';

import '../../models/account.model.dart';

part 'account_list_event.dart';
part 'account_list_state.dart';

class AccountListBloc extends Bloc<AccountListEvent, AccountListState> {
  AccountRepository _repo;

  AccountListBloc(this._repo)
      : super(AccountInitial(totalBalanceInFiat: '0', accounts: [])) {
    this._repo.listener.listen((msg) {
      if (msg.evt == ACCOUNT_EVT.OnUpdateAccount) {
        String totalBalanceInFiat = msg.value["totalBalanceInFiat"];
        List<Account> accounts = msg.value["accounts"];
        // Fiat? fiat = msg.value["fiat"];

        this.add(UpdateAccounts(
            totalBalanceInFiat: totalBalanceInFiat, accounts: accounts));
      }

      if (msg.evt == ACCOUNT_EVT.ClearAll) {
        this.add(CleanAccounts());
      }
    });
  }

  @override
  Future<void> close() {
    _repo.listener.close();
    return super.close();
  }

  @override
  Stream<AccountListState> mapEventToState(
    AccountListEvent event,
  ) async* {
    if (event is OverView) {
      Map data = await _repo.getOverview();
      yield AccountLoaded(
          totalBalanceInFiat: data['totalBalanceInFiat'],
          accounts: data['accounts']);
    }
    if (event is UpdateAccounts) {
      yield AccountLoaded(
          totalBalanceInFiat: event.totalBalanceInFiat,
          accounts: event.accounts);
    }

    if (event is CleanAccounts) {
      yield AccountLoaded(totalBalanceInFiat: '0', accounts: []);
    }
  }
}
