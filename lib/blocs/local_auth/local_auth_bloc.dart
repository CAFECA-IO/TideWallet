import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../repositories/local_auth_repository.dart';

part 'local_auth_event.dart';
part 'local_auth_state.dart';

class LocalAuthBloc extends Bloc<LocalAuthEvent, LocalAuthState> {
  LocalAuthRepository _repo;
  LocalAuthBloc(this._repo) : super(LocalAuthInitial(false));

  @override
  Stream<LocalAuthState> mapEventToState(
    LocalAuthEvent event,
  ) async* {
    if (event is Authenticate) {
      bool isAuthenticated = await _repo.authenticateUser();
      yield AuthenticationStatus(isAuthenticated);
    }
  }
}
