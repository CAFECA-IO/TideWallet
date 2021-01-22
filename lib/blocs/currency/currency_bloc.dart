import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:tidewallet3/constants/account_config.dart';
import 'package:tidewallet3/models/account.model.dart';
import 'package:tidewallet3/repositories/account_repository.dart';

part 'currency_event.dart';
part 'currency_state.dart';

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  AccountRepository _repo;
  StreamSubscription _subscription;

  CurrencyBloc(this._repo) : super(CurrencyInitial([], total: Decimal.zero)) {
    _subscription?.cancel();
    this._repo.listener.listen((msg) {
      if (msg.evt == ACCOUNT_EVT.OnUpdateToken) {
        this.add(UpdateCurrency(msg.value));
      }
    });

    this._repo.coreInit();
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
      final List<Currency> list = _repo.getCurrencies(event.account);
      Decimal _total = Decimal.zero;
      list.forEach((curr) {
        _total += Decimal.tryParse(curr.fiat);
      });
      yield CurrencyLoaded(list, total: _total);
    }
  }
}
