import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import '../../repositories/account_repository.dart';
import '../../repositories/trader_repository.dart';
import '../../models/account.model.dart';

part 'account_currency_event.dart';
part 'account_currency_state.dart';

class AccountCurrencyBloc
    extends Bloc<AccountCurrencyEvent, AccountCurrencyState> {
  AccountRepository _repo;
  TraderRepository _traderRepo;
  StreamSubscription _subscription;

  AccountCurrencyBloc(this._repo, this._traderRepo)
      : super(AccountCurrencyInitial([], total: Decimal.zero)) {
    _subscription?.cancel();

    this._repo.listener.listen((msg) {
      if (msg.evt == ACCOUNT_EVT.OnUpdateCurrency) {
        this.add(UpdateAccountCurrencies(msg.value));
      }

      if (msg.evt == ACCOUNT_EVT.ClearAll) {
        this.add(CleanAccountCurrencies());
      }
    });
  }

  @override
  Future<void> close() {
    _repo.listener.close();
    return super.close();
  }

  @override
  Stream<AccountCurrencyState> mapEventToState(
    AccountCurrencyEvent event,
  ) async* {
    if (event is GetCurrencyList) {
      List<Currency> list = [];

      list = _repo.getAllCurrencies();

      Decimal _total = Decimal.zero;

      list = list.map((curr) {
        Decimal v = _traderRepo.calculateToUSD(curr);
        _total += v;

        return curr.copyWith(inUSD: v.toString());
      }).toList();

      yield AccountCurrencyLoaded(list, total: _total);
    }
    if (event is UpdateAccountCurrencies) {
      List<Currency> _list = state.currencies;
      event.currencies.forEach((newCurr) {
        int index = state.currencies
            .indexWhere((oldCurr) => oldCurr.accountId == newCurr.accountId);
        if (index < 0)
          _list.add(newCurr);
        else
          _list[index] = newCurr;
      });

      Decimal _total = Decimal.zero;

      _list = _list.map(
        (e) {
          Decimal v = _traderRepo.calculateToUSD(e);
          _total += v;

          return e.copyWith(inUSD: v.toString());
        },
      ).toList();

      yield AccountCurrencyLoaded(_list, total: _total);

      List<Currency> _accounts = [...state.currencies];

      _accounts.forEach((acc) {
        _repo.getCurrencies(acc.accountId).forEach((currency) {
          Decimal v = _traderRepo.calculateToUSD(currency);
          _total += v;
        });
      });

      _accounts
          .sort((a, b) => a.accountType.index.compareTo(b.accountType.index));

      yield AccountCurrencyLoaded(_accounts, total: _total);
    }

    if (event is CleanAccountCurrencies) {
      List<Currency> empty = [];
      yield AccountCurrencyLoaded(empty, total: Decimal.zero);
    }
  }
}
