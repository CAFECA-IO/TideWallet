import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

// import '../../helpers/logger.dart';
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
      var options = _repo.displayCurrencies;
      final selected = await _repo.getSeletedDisplay();

      if (selected != null) {
        options = options.map((opt) {
          if (selected[opt.currencyId] == true) {
            return opt.copyWith(opened: true);
          } else {
            return opt;
          }
        }).toList();
      }
      // yield ToggleTokenLoaded(this.getOtions(options));
      yield ToggleTokenLoaded(options);
    }

    if (event is ToggleToken) {
      ToggleTokenLoaded _state = state as ToggleTokenLoaded;
      List<DisplayCurrency> _list = [..._state.list];

      int index =
          _list.indexWhere((el) => el.currencyId == event.currency.currencyId);
      _list[index] = _list[index].copyWith(opened: event.value);

      yield ToggleTokenLoaded(_list);
      Currency cur = Currency(
          accountId: _list[index].accountId,
          currencyId: _list[index].currencyId,
          blockchainId: _list[index].blockchainId);

      if (event.value == true) {
        Token token =
            Token(contract: _list[index].contract, imgUrl: _list[index].icon);

        bool success = await _repo.addToken(cur, token);
        if (!success) throw Exception('Failed to add toggle');
      }
      await _repo.toggleDisplay(cur, event.value);
    }
  }
}
