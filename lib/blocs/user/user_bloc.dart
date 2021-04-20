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

  UserBloc(this._repo, this._accountRepo) : super(UserInitial());

  @override
  Stream<UserState> mapEventToState(
    UserEvent event,
  ) async* {
    if (event is UserCheck) {
      bool existed = await _repo.checkUser();

      if (existed) {
        if (event.debugMode ?? false) yield UserInitial();
        await _accountRepo.coreInit(debugMode: event.debugMode ?? false);
        await Future.delayed(Duration(milliseconds: 100));

        yield UserSuccess();
      } else {
        yield UserFail();
      }
    }

    if (event is UserCreate) {
      yield UserLoading();
      bool success = await _repo.createUser(event.userIndentifier);
      if (success) {
        await _accountRepo.coreInit();
        yield UserSuccess();
      } else {
        yield UserFail();
      }
    }


    if (event is UserCreateWithSeed) {
      yield UserLoading();
      bool success = await _repo.createUserWithSeed(event.userIndentifier, event.seed);
      if (success) {
        await _accountRepo.coreInit();
        yield UserSuccess();
      } else {
        yield UserFail();
      }
    }

    if (event is UserRestore) {
      yield UserLoading();
      await _accountRepo.coreInit();

      yield UserSuccess();
    }

    if (event is UserReset) {
      yield UserFail();
    }
  }
}
