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
  Currency _parentAccount;
  AddCurrencyBloc(this._repo, {Currency currency})
      : this._parentAccount = currency,
        super(BeforeAdd(valid: false, address: ''));

  @override
  Stream<Transition<AddCurrencyEvent, AddCurrencyState>> transformEvents(
      Stream<AddCurrencyEvent> events, transitionFn) {
    final nonDebounceStream = events.where((event) => event is! GetTokenInfo);

    final debounceStream = events
        .where((event) => event is GetTokenInfo)
        .debounceTime(Duration(milliseconds: 1000));

    return super.transformEvents(
        MergeStream([nonDebounceStream, debounceStream]), transitionFn);
  }

  @override
  Stream<AddCurrencyState> mapEventToState(
    AddCurrencyEvent event,
  ) async* {
    if (event is EnterAddress) {
      bool valid = _repo.validateETHAddress(event.address);
      yield BeforeAdd(address: event.address, valid: valid);

      if (valid) {
        this.add(GetTokenInfo(event.address));
      }
    }

    if (event is GetTokenInfo) {
      // BeforeAdd _state = state;

      yield Loading();

      Token _tk = await _repo.getTokenInfo(
          this._parentAccount.blockchainId, event.address);
      if (_tk != null) {
        yield GetToken(_tk);
      } else {
        yield GetToken(null);
      }
    }

    if (event is AddToken) {
      GetToken _state = state;
      yield Loading();

      bool result =
          await _repo.addToken(_parentAccount.blockchainId, _state.result);

      if (result) {
        yield AddSuccess();
      } else {
        yield AddFail();

        await Future.delayed(Duration(milliseconds: 200));
        yield BeforeAdd();
      }
    }
  }
}
