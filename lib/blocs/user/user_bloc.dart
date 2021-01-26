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
    if (event is UserCreate) {
      _repo.createUser();
      yield UserSuccess();
    }

    if (event is UserRestore) {
      yield UserSuccess();
    }

    if (event is VerifyPassword) {
      yield VerifyingPassword();
      if (_repo.verifyPassword(event.password)) {
        yield PasswordVerified();
      } else {
        yield PasswordInvalid();
      }
    }
    if (event is UpdatePassword) {
      yield PasswordUpdated();
    }
  }
}
