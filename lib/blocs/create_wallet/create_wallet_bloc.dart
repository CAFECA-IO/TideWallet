import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import '../../helpers/validator.dart';

part 'create_wallet_event.dart';
part 'create_wallet_state.dart';

class CreateWalletBloc extends Bloc<CreateWalletEvent, CreateWalletState> {
  CreateWalletBloc() : super(CreateWalletCheck());
  Validator _validator = new Validator();

  CreateFormError validateState(CreateWalletCheck state) {
    if (state.name.isEmpty) return CreateFormError.nameEmpty;
    if (state.rules.contains(false)) return CreateFormError.passwordInvalid;
    if (state.password != state.rePassword) return CreateFormError.passwordNotMatch;

    return CreateFormError.none;
  }

  @override
  Stream<CreateWalletState> mapEventToState(
    CreateWalletEvent event,
  ) async* {
    CreateWalletCheck _state = state;
    
    if (event is InputWalletName) {
      if (_state.password.isNotEmpty) {
        yield _state.copyWith(
          name: event.name,
          rules: _validator.validPassword(_state.password, event.name),
        );
      } else {
        yield _state.copyWith(name: event.name);
      }
    }

    if (event is InputPassword) {
      yield _state.copyWith(
          password: event.password,
          rules: _validator.validPassword(event.password, _state.name));
    }

    if (event is InputRePassword) {
      yield _state.copyWith(rePassword: event.password);
    }

    if (event is SubmitCreateWallet) {
      
      yield _state.copyWith(error: this.validateState(_state));
    }
    
    if (event is CleanCreateWalletError) {
      
      yield _state.copyWith(error: null);
    }
  }
}
