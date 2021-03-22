import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import '../../models/account.model.dart';
import '../../repositories/account_repository.dart';
import '../../repositories/trader_repository.dart';

part 'currency_event.dart';
part 'currency_state.dart';

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  AccountRepository _repo;
  TraderRepository _traderRepo;

  StreamSubscription _subscription;

  CurrencyBloc(this._repo, this._traderRepo)
      : super(CurrencyInitial([], total: Decimal.zero)) {
    _subscription?.cancel();
    this._repo.listener.listen((msg) {
      if (msg.evt == ACCOUNT_EVT.OnUpdateCurrency) {
        this.add(UpdateCurrencies(msg.value));
      }

      if (msg.evt == ACCOUNT_EVT.ClearAll) {
        this.add(CleanCurrencie());
      }
    });
  }

  @override
  Future<void> close() {
    return super.close();
  }

  @override
  Stream<CurrencyState> mapEventToState(
    CurrencyEvent event,
  ) async* {
    if (event is GetCurrencyList) {
      List<Currency> list = _repo.getCurrencies(event.accountId);
      Decimal _total = Decimal.zero;

      list = list.map((curr) {
        Decimal v = _traderRepo.calculateToUSD(curr);

        _total += v;

        return curr.copyWith(inUSD: v.toString());
      }).toList();

      yield CurrencyLoaded(list, total: _total);
    }

    if (event is UpdateCurrencies) {
      if (event.currenices[0].accountType == state.currencies[0].accountType) {
        List<Currency> _list = event.currenices;
        Decimal _total = Decimal.zero;

        _list = _list.map(
          (e) {
            Decimal v = _traderRepo.calculateToUSD(e);
            _total += v;

            return e.copyWith(inUSD: v.toString());
          },
        ).toList();

        yield CurrencyLoaded(_list, total: _total);
      }
    }

    if (event is CleanCurrencie) {
      List<Currency> empty = [];
      yield CurrencyLoaded(empty, total: Decimal.zero);
    }
  }
}
