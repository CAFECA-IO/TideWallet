import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../repositories/user_repository.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserRepository _repo;
  UserBloc(this._repo) : super(UserInitial());

  @override
  Stream<UserState> mapEventToState(
    UserEvent event,
  ) async* {
    if (event is UserCheck) {
      bool existed = await _repo.checkUser();

      if (existed) {
        yield UserSuccess();
      }
    }

    if (event is UserCreate) {
      yield UserLoading();
      bool success = await _repo.createUser(event.password, event.walletName);
      if (success) {
        yield UserSuccess();
      } else {
        yield UserFail();
      }
    }

    if (event is UserRestore) {
      yield UserLoading();
      yield UserSuccess();
    }

    if (event is VerifyPassword) {
      yield VerifyingPassword();
      if (_repo.verifyPassword(event.password)) {
        yield PasswordVerified(event.password);
      } else {
        yield PasswordInvalid();
      }
    }
    if (event is UpdatePassword) {
      yield PasswordUpdated();
    }
  }
}
