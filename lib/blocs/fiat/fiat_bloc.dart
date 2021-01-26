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
        Fiat selted = await _repo.getSelectedFiat() ?? res[0];
        
        yield FiatLoaded(list: res, fiat: selted);
      }
  }
}
