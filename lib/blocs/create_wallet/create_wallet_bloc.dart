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

  @override
  Stream<CreateWalletState> mapEventToState(
    CreateWalletEvent event,
  ) async* {
     CreateWalletCheck _state = state;
    if (event is InputPassword) {
      yield _state.copyWith(password: event.password, rules: _validator.validPassword(event.password, _state.name));
    }
  }
}
