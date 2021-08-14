import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import '../../repositories/account_repository.dart';
import '../../repositories/trader_repository.dart';
import '../../models/account.model.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  late AccountRepository _repo;
  late TraderRepository _traderRepo;
  late StreamSubscription? _subscription;

  AccountBloc(this._repo, this._traderRepo)
      : super(AccountInitial([], total: Decimal.zero)) {
    _subscription?.cancel();

    this._repo.listener.listen((msg) {
      if (msg.evt == ACCOUNT_EVT.OnUpdateAccount) {
        List<Account> currencies = msg.value;

        this.add(UpdateAccounts(currencies));
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

  List<Account> displayFilter(List<Account> accounts) {
    final display = this._repo.preferDisplay;
    if (this._repo.debugMode) return accounts;
    return accounts
        .where((acc) =>
            acc.publish ||
            (display[acc.currencyId] != null &&
                display[acc.currencyId] == true))
        .toList();
  }

  @override
  Stream<AccountState> mapEventToState(
    AccountEvent event,
  ) async* {
    if (event is GetAccountList) {
      List<Account> list = [];

      list = _repo.getAllAccounts();
      list = this.displayFilter(list);

      Decimal _total = Decimal.zero;

      list = list.map((curr) {
        Decimal v = _traderRepo.calculateToUSD(curr);
        _total += v;

        return curr.copyWith(inFiat: v.toString());
      }).toList();

      list.sort((a, b) => a.accountType.index.compareTo(b.accountType.index));

      yield AccountLoaded(list, total: _total);
    }
    if (event is UpdateAccounts) {
      List<Account> _list = [...state.accounts];
      List<Account> _filter = this.displayFilter(event.accounts);

      final _currency = _filter.map((e) {
        Decimal v = _traderRepo.calculateToUSD(e);

        return e.copyWith(inFiat: v.toString());
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
        _total += Decimal.parse(c.inFiat);
      });

      _list.sort((a, b) => a.accountType.index.compareTo(b.accountType.index));

      yield AccountLoaded(_list, total: _total);
    }

    if (event is CleanAccounts) {
      List<Account> empty = [];
      yield AccountLoaded(empty, total: Decimal.zero);
    }

    if (event is ToggleDisplay) {
      AccountLoaded _state = state as AccountLoaded;
      List<Account> _list = [..._state.accounts];

      int index =
          _state.accounts.indexWhere((el) => el.currencyId == event.currencyId);

      if (index > -1) {
        _list.removeAt(index);
      }
      Decimal _total = Decimal.zero;

      _list = _list.map((curr) {
        Decimal v = _traderRepo.calculateToUSD(curr);
        _total += v;

        return curr.copyWith(inFiat: v.toString());
      }).toList();

      _list.sort((a, b) => a.accountType.index.compareTo(b.accountType.index));

      yield AccountLoaded(_list, total: _total);
    }
  }
}
