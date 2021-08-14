import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../repositories/local_auth_repository.dart';
// import '../../services/fcm_service.dart';

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
      if (isAuthenticated) {
        // FCM().emmiter.sink.add(FCM_LOCAL_EVENT.UNLOCK_APP);
      }

      yield AuthenticationStatus(isAuthenticated);
    }

    if (event is InitAuth) {
      yield LocalAuthInitial(false);
    }
  }
}
