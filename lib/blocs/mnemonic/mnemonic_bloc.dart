import 'dart:async';
import 'dart:io';
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
      MnemonicTyping _state = state as MnemonicTyping;

      yield _state.copyWith(mnemonic: event.text, error: MNEMONIC_ERROR.NONE);
    }

    if (event is InputMnemoPassword) {
      MnemonicTyping _state = state as MnemonicTyping;

      yield _state.copyWith(
          passphrase: event.password, error: MNEMONIC_ERROR.NONE);
    }

    if (event is InputMnemoRePassword) {
      MnemonicTyping _state = state as MnemonicTyping;

      yield _state.copyWith(
          rePassphrase: event.password, error: MNEMONIC_ERROR.NONE);
    }

    if (event is SubmitMnemonic) {
      MnemonicTyping _state = state as MnemonicTyping;

      if (_state.passphrase != _state.rePassphrase) {
        yield (_state.copyWith(error: MNEMONIC_ERROR.PASSWORD_NOT_MATCH));
      } else {
        yield MnemonicLoading();

        bool valid = await _repo.checkMnemonicVaildity(_state.mnemonic);

        if (valid) {
          Uint8List seed = await _repo.mnemonicToSeed(
              _state.mnemonic.trimRight(), _state.passphrase);
          try {
            yield MnemonicSuccess(_repo.thirdPartyId, seed);
          } catch (e) {
            yield _state.copyWith(error: MNEMONIC_ERROR.LOGIN);
          }
        } else {
          yield _state.copyWith(error: MNEMONIC_ERROR.MNEMONIC_INVALID);
        }
      }
    }
  }
}
