import 'dart:async';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../repositories/user_repository.dart';
import '../../repositories/account_repository.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserRepository _repo;
  AccountRepository _accountRepo;
  bool _debugMode = false;

  UserBloc(this._repo, this._accountRepo) : super(UserInitial());

  @override
  Stream<UserState> mapEventToState(
    UserEvent event,
  ) async* {
    if (event is UserInit) {
      yield UserLoading();
      await _accountRepo.coreInit(debugMode: this._debugMode);
      yield UserAuthenticated();
    }

    if (event is UserCheck) {
      bool existed = await _repo.checkUser();
      if (event.debugMode != null) this._debugMode = event.debugMode!;
      if (existed) {
        yield UserSuccess();
      } else {
        yield UserFail();
      }
    }

    if (event is UserCreate) {
      yield UserLoading();
      bool success = await _repo.createUser(event.userIndentifier);
      if (success) {
        yield UserSuccess();
      } else {
        yield UserFail();
      }
    }

    if (event is UserCreateWithSeed) {
      yield UserLoading();
      bool success =
          await _repo.createUserWithSeed(event.userIndentifier, event.seed);
      if (success) {
        yield UserSuccess();
      } else {
        yield UserFail();
      }
    }

    if (event is UserReset) {
      yield UserFail();
    }
  }
}
