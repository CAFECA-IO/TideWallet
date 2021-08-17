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

  @override
  Stream<ToggleTokenState> mapEventToState(
    ToggletokenEvent event,
  ) async* {
    if (event is InitTokens) {
      List<DisplayToken> options = await _repo.getDisplayTokens();
      yield ToggleTokenLoaded(options);
    }

    if (event is ToggleToken) {
      ToggleTokenLoaded _state = state as ToggleTokenLoaded;
      List<DisplayToken> _list = [..._state.list];

      int index =
          _list.indexWhere((el) => el.currencyId == event.currency.currencyId);
      _list[index] = _list[index].copyWith(opened: event.value);

      yield ToggleTokenLoaded(_list);

      await _repo.toggleDisplayToken(_list[index]);
    }
  }
}
