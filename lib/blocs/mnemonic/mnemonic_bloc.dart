import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'mnemonic_event.dart';
part 'mnemonic_state.dart';

class MnemonicBloc extends Bloc<MnemonicEvent, MnemonicState> {
  MnemonicBloc() : super(MnemonicTyping());

  @override
  Stream<MnemonicState> mapEventToState(
    MnemonicEvent event,
  ) async* {
    if (event is InputMnemo) {
      MnemonicTyping _state = state;
      MNEMONIC_ERROR error = _state.rePassword == _state.password
          ? MNEMONIC_ERROR.NONE
          : MNEMONIC_ERROR.PASSWORD_NOT_MATCH;

      yield _state.copyWith(mnemonic: event.text, error: error);
    }

    if (event is InputMnemoPassword) {
      MnemonicTyping _state = state;

      MNEMONIC_ERROR error = _state.rePassword == event.password
          ? MNEMONIC_ERROR.NONE
          : MNEMONIC_ERROR.PASSWORD_NOT_MATCH;

      yield _state.copyWith(password: event.password, error: error);
    }

    if (event is InputMnemoRePassword) {
      MnemonicTyping _state = state;

      MNEMONIC_ERROR error = _state.password == event.password
          ? MNEMONIC_ERROR.NONE
          : MNEMONIC_ERROR.PASSWORD_NOT_MATCH;

      yield _state.copyWith(rePassword: event.password, error: error);
    }

    if (event is SubmitMnemonic) {
      MnemonicTyping _state = state;
      yield MnemonicLoading();

      yield MnemonicSuccess('seed');
    }
  }
}
