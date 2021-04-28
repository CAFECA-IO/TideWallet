import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/account.model.dart';
import '../../repositories/trader_repository.dart';

part 'fiat_event.dart';
part 'fiat_state.dart';

class FiatBloc extends Bloc<FiatEvent, FiatState> {
  TraderRepository _repo;
  FiatBloc(this._repo) : super(FiatInitial());

  @override
  Stream<FiatState> mapEventToState(
    FiatEvent event,
  ) async* {
    if (event is GetFiatList) {
      List<Fiat> res = await _repo.getFiatList();
      Fiat selected = await _repo.getSelectedFiat();
      _repo.setFiat = selected;

      yield FiatLoaded(list: res, fiat: selected);
    }

    if (event is SwitchFiat) {
      FiatLoaded _state = state;
      await _repo.changeSelectedFiat(event.fiat);

      yield _state.copyWith(fiat: event.fiat);
    }
  }
}
