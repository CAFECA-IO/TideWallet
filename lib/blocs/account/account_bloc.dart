import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import '../../repositories/account_repository.dart';

import '../../models/account.model.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountRepository _repo;

  AccountBloc(this._repo)
      : super(AccountInitial(totalBalanceInFiat: '0', accounts: [])) {
    this._repo.listener.listen((msg) {
      if (msg.evt == ACCOUNT_EVT.OnUpdateAccount) {
        String totalBalanceInFiat = msg.value["totalBalanceInFiat"];
        List<Account> accounts = msg.value["accounts"];
        Fiat? fiat = msg.value["fiat"];

        this.add(UpdateAccounts(
            totalBalanceInFiat: totalBalanceInFiat,
            accounts: accounts,
            fiat: fiat));
      }

      if (msg.evt == ACCOUNT_EVT.ClearAll) {
        this.add(CleanAccounts());
      }

      if (msg.evt == ACCOUNT_EVT.ToggleDisplayCurrency) {
        this.add(ToggleDisplay(msg.value));
      }
    });
  }

  @override
  Future<void> close() {
    _repo.listener.close();
    return super.close();
  }

  @override
  Stream<AccountState> mapEventToState(
    AccountEvent event,
  ) async* {
    if (event is OverView) {
      List<Account> accounts = _repo.getAllAccounts();
      yield AccountLoaded(
          totalBalanceInFiat: totalBalanceInFiat,
          accounts: accounts,
          fiat: fiat);
    }
    if (event is UpdateAccounts) {
      yield AccountLoaded(
          totalBalanceInFiat: event.totalBalanceInFiat,
          accounts: event.accounts,
          fiat: event.fiat ?? state.fiat);
    }

    if (event is CleanAccounts) {
      List<Account> empty = [];
      yield AccountLoaded(
          totalBalanceInFiat: '0', accounts: [], fiat: state.fiat);
    }

    if (event is ToggleDisplay) {
      yield AccountLoaded(
          totalBalanceInFiat: event.totalBalanceInFiat,
          accounts: event.accounts,
          fiat: event.fiat ?? state.fiat);
    }
  }
}
