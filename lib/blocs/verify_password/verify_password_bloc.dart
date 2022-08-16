import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../repositories/user_repository.dart';

part 'verify_password_event.dart';
part 'verify_password_state.dart';

class VerifyPasswordBloc
    extends Bloc<VerifyPasswordEvent, VerifyPasswordState> {
  UserRepository _repo;
  VerifyPasswordBloc(this._repo) : super(VerifyPasswordInitial());

  @override
  Stream<VerifyPasswordState> mapEventToState(
    VerifyPasswordEvent event,
  ) async* {
    if (event is VerifyPassword) {
      yield VerifyingPassword();
      // if (_repo.verifyPassword(event.password)) {
      //   yield PasswordVerified(event.password);
      // } else {
      //   yield PasswordInvalid();
      // }
    }
  }
}
