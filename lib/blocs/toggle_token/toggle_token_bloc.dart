import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tidewallet3/helpers/logger.dart';
import 'package:tidewallet3/models/account.model.dart';
import 'package:tidewallet3/repositories/account_repository.dart';

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
      Map options = _repo.displayCurrencies;
      Log.debug(options);
      yield ToggleTokenLoaded(this.getOtions(options));
    }
  }
}
