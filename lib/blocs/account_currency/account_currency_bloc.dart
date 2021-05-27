import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
// import 'package:tidewallet3/helpers/logger.dart';

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
        List<Currency> currencies = msg.value;

        this.add(UpdateAccountCurrencies(currencies));
      }

      if (msg.evt == ACCOUNT_EVT.ClearAll) {
        this.add(CleanAccountCurrencies());
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

  List<Currency> displayFilter(List<Currency> currencies) {
    final display = this._repo.preferDisplay;

    return currencies
        .map((cur) {
          if (cur.type != 'token') {
            return cur;
          } else {
            if (display != null && display[cur.currencyId] == true) {
              return cur;
            }

            return null;
          }
        })
        .where((el) => el != null)
        .toList();
  }

  @override
  Stream<AccountCurrencyState> mapEventToState(
    AccountCurrencyEvent event,
  ) async* {
    if (event is GetCurrencyList) {
      List<Currency> list = [];

      list = _repo.getAllCurrencies();
      list = this.displayFilter(list);

      Decimal _total = Decimal.zero;

      list = list.map((curr) {
        Decimal v = _traderRepo.calculateToUSD(curr);
        _total += v;

        return curr.copyWith(inUSD: v.toString());
      }).toList();

      list.sort((a, b) => a.accountType.index.compareTo(b.accountType.index));

      yield AccountCurrencyLoaded(list, total: _total);
    }
    if (event is UpdateAccountCurrencies) {
      List<Currency> _list = [...state.currencies];
      List<Currency> _filter = this.displayFilter(event.currencies);

      final _currency = _filter.map((e) {
        Decimal v = _traderRepo.calculateToUSD(e);

        return e.copyWith(inUSD: v.toString());
      }).toList();

      _currency.forEach((newCurr) {
        int index = _list.indexWhere((oldCurr) => oldCurr.id == newCurr.id);
        if (index < 0) {
          _list.add(newCurr);
        } else {
          _list[index] = newCurr;
        }
      });

      Decimal _total = Decimal.zero;

      _list.forEach((c) {
        _total += Decimal.parse(c.inUSD);
      });

      _list.sort((a, b) => a.accountType.index.compareTo(b.accountType.index));

      yield AccountCurrencyLoaded(_list, total: _total);
    }

    if (event is CleanAccountCurrencies) {
      List<Currency> empty = [];
      yield AccountCurrencyLoaded(empty, total: Decimal.zero);
    }

    if (event is ToggleDisplay) {
      AccountCurrencyLoaded _state = state;
      List<Currency> _list = [..._state.currencies];

      int index = _state.currencies
          .indexWhere((el) => el.currencyId == event.currencyId);

      if (index > -1) {
        _list.removeAt(index);
      }
      Decimal _total = Decimal.zero;

      _list = _list.map((curr) {
        Decimal v = _traderRepo.calculateToUSD(curr);
        _total += v;

        return curr.copyWith(inUSD: v.toString());
      }).toList();

      _list.sort((a, b) => a.accountType.index.compareTo(b.accountType.index));

      yield AccountCurrencyLoaded(_list, total: _total);
    }
  }
}
