import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../repositories/third_party_sign_in_repository.dart';

part 'mnemonic_event.dart';
part 'mnemonic_state.dart';

class MnemonicBloc extends Bloc<MnemonicEvent, MnemonicState> {
  ThirdPartySignInRepository _repo;
  MnemonicBloc(this._repo) : super(MnemonicTyping());

  @override
  Stream<MnemonicState> mapEventToState(
    MnemonicEvent event,
  ) async* {
    if (event is InputMnemo) {
      MnemonicTyping _state = state;
      // MNEMONIC_ERROR error = _state.rePassword == _state.password
      //     ? MNEMONIC_ERROR.NONE
      //     : MNEMONIC_ERROR.PASSWORD_NOT_MATCH;

      yield _state.copyWith(mnemonic: event.text, error: MNEMONIC_ERROR.NONE);
    }

    if (event is InputMnemoPassword) {
      MnemonicTyping _state = state;

      // MNEMONIC_ERROR error = _state.rePassword == event.password
      //     ? MNEMONIC_ERROR.NONE
      //     : MNEMONIC_ERROR.PASSWORD_NOT_MATCH;

      yield _state.copyWith(password: event.password, error: MNEMONIC_ERROR.NONE);
    }

    if (event is InputMnemoRePassword) {
      MnemonicTyping _state = state;

      // MNEMONIC_ERROR error = _state.password == event.password
      //     ? MNEMONIC_ERROR.NONE
      //     : MNEMONIC_ERROR.PASSWORD_NOT_MATCH;

      yield _state.copyWith(rePassword: event.password, error: MNEMONIC_ERROR.NONE);
    }

    if (event is SubmitMnemonic) {
      MnemonicTyping _state = state;

      if (_state.password != _state.rePassword) {
        yield (_state.copyWith(error: MNEMONIC_ERROR.PASSWORD_NOT_MATCH));
      } else {
        yield MnemonicLoading();

        bool valid = await _repo.checkMnemonicVaildity(_state.mnemonic);
        print('Mnemonic valid? $valid');

        if (valid) {
          Uint8List seed =
              await _repo.mnemonicToSeed(_state.mnemonic, _state.password);
      
          List result = await _repo.signInWithAppleId();
          print(result);

          if (result[0]) {
            yield MnemonicSuccess('seed');
          } else {
            yield _state;
          }
        } else {
          yield _state.copyWith(error: MNEMONIC_ERROR.MNEMONIC_INVALID);
        }
      }
    }
  }
}
