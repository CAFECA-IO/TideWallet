import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:equatable/equatable.dart';

import '../../models/account.model.dart';
import '../../repositories/account_repository.dart';

part 'add_currency_event.dart';
part 'add_currency_state.dart';

class AddCurrencyBloc extends Bloc<AddCurrencyEvent, AddCurrencyState> {
  AccountRepository _repo;
  AddCurrencyBloc(this._repo)
      : super(
            BeforeAdd(valid: false, address: '', result: null, loading: false));

  @override
  Stream<Transition<AddCurrencyEvent, AddCurrencyState>> transformEvents(
      Stream<AddCurrencyEvent> events, transitionFn) {
    final nonDebounceStream = events.where((event) => event is! GetTokenInfo);

    final debounceStream = events
        .where((event) => event is GetTokenInfo)
        .debounceTime(Duration(milliseconds: 500));

    return super.transformEvents(
        MergeStream([nonDebounceStream, debounceStream]), transitionFn);
  }

  @override
  Stream<AddCurrencyState> mapEventToState(
    AddCurrencyEvent event,
  ) async* {
    if (event is EnterAddress) {
      BeforeAdd _state = state;

      bool valid = _repo.validateETHAddress(event.address);
      yield _state.copyWith(address: event.address, valid: valid, result: null);

      if (valid) {
        this.add(GetTokenInfo(event.address));
      }
    }

    if (event is GetTokenInfo) {
      BeforeAdd _state = state;

      Token _tk = await _repo.getTokenInfo(event.address);
      if (_tk != null) {
        yield _state.copyWith(result: _tk);
      }
    }

    if (event is AddToken) {
      BeforeAdd _state = state;
      yield _state.copyWith(loading: true);

      bool result = await _repo.addToken(_state.result);

      if (result) {
        yield AddSuccess();
      } else {
        yield AddFail();

        await Future.delayed(Duration(milliseconds: 200));
        yield _state.copyWith(result: _state.result);
      }
    }
  }
}
