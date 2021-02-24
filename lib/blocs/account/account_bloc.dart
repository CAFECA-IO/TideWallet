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
  AccountRepository _repo;
  TraderRepository _traderRepo;
  StreamSubscription _subscription;

  AccountBloc(this._repo, this._traderRepo) : super(AccountInitial()) {
    _subscription?.cancel();
    this._repo.listener.listen((msg) {
      if (msg.evt == ACCOUNT_EVT.OnUpdateAccount) {
        this.add(UpdateAccount(msg.value));
      }


      if (msg.evt == ACCOUNT_EVT.ClearAll) {
        this.add(CleanAccount());
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
    if (event is UpdateAccount) {
      AccountState _state = state;

      int index = _state.accounts
          .indexWhere((account) => account.symbol == event.account.symbol);

      Currency acc = event.account;
      List<Currency> list = _repo.getCurrencies(acc.accountType);

      Decimal _usd = Decimal.zero;

      list.forEach((curr) {
        Decimal v = _traderRepo.calculateToUSD(curr);
        _usd += v;
      });

      acc = acc.copyWith(inUSD: _usd.toString());

      List<Currency> _accounts = [..._state.accounts];
      if (index < 0) {
        _accounts.add(acc);
      } else {
        _accounts[index] = acc;
      }

      Decimal _total = Decimal.zero;

      _accounts.forEach((acc) {
        _repo.getCurrencies(acc.accountType).forEach((currency) {
          Decimal v = _traderRepo.calculateToUSD(currency);
          _total += v;
        });
      });

      _accounts.sort((a, b) => a.accountType.index.compareTo(b.accountType.index));

      yield AccountLoaded(_accounts, total: _total);
    }

    if (event is CleanAccount) {
      List<Currency> empty = [];
      yield AccountLoaded(empty, total: Decimal.zero);
    }
  }
}
