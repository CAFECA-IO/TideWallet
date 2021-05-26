import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../helpers/logger.dart';
import '../../models/account.model.dart';
import '../../repositories/account_repository.dart';

part 'toggle_token_event.dart';
part 'toggle_token_state.dart';

class ToggleTokenBloc extends Bloc<ToggletokenEvent, ToggleTokenState> {
  AccountRepository _repo;
  ToggleTokenBloc(this._repo) : super(ToggleTokenInitial());

  List<DisplayCurrency> getOtions(Map options) {
    List<DisplayCurrency> reuslt = [];
    options.entries.forEach((element) {
      Log.warning(element);
      reuslt += element.value;
    });

    return reuslt;
  }

  @override
  Stream<ToggleTokenState> mapEventToState(
    ToggletokenEvent event,
  ) async* {
    if (event is InitTokens) {
      // Map options = _repo.displayCurrencies;
      List options = _repo.displayCurrencies;
      Log.debug(options);
      // yield ToggleTokenLoaded(this.getOtions(options));
      yield ToggleTokenLoaded(options);
    }

    if (event is ToggleToken) {
      ToggleTokenLoaded _state = state;
      List<DisplayCurrency> _list = [..._state.list];

      int index =
          _list.indexWhere((el) => el.currencyId == event.currency.currencyId);
      _list[index] = _list[index].copyWith(opened: event.value);

      if (event.value == true) {
        Token token = Token(
          contract: _list[index].contract
        );
        String accountId = await _repo.addToken(_list[index].blockchainId, token);

        Currency cur = Currency(
            accountId: accountId,
            currencyId: _list[index].currencyId,
            );
        _repo.toggleDisplay(cur, event.value);

      } else {
        final data = _repo.getSeletedDisplay();
        Log.warning(data);
      }


      yield ToggleTokenLoaded(_list);
    }
  }
}
