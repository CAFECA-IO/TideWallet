import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../repositories/third_party_sign_in_repository.dart';
import '../../helpers/logger.dart';

part 'third_party_sign_in_event.dart';
part 'third_party_sign_in_state.dart';

class ThirdPartySignInBloc
    extends Bloc<ThirdPartySignInEvent, ThirdPartySignInState> {
  final ThirdPartySignInRepository _repo;
  ThirdPartySignInBloc(this._repo) : super(ThirdPartySignInInitial());

  @override
  Stream<ThirdPartySignInState> mapEventToState(
    ThirdPartySignInEvent event,
  ) async* {
    if (event is SignInWithApple) {
      try {
        List response = await this._repo.signInWithAppleId();
        bool success = response[0];

        if (success) {
          String userIndentifier = response[1];
          yield SignedInWithApple(userIndentifier);
        } else {
          AuthorizationErrorCode errorCode = response[1];
          switch (errorCode) {
            case AuthorizationErrorCode.canceled:
              yield CancelledSignInWithApple();
              break;
            case AuthorizationErrorCode.failed:
            case AuthorizationErrorCode.invalidResponse:
            case AuthorizationErrorCode.notHandled:
            case AuthorizationErrorCode.unknown:
              String message = response[2];
              yield FailedSignInWithApple(message);
              break;
          }
          yield FailedSignInWithApple('Something went wrong...');
        }
      } catch (e) {
        Log.debug(e);
        yield FailedSignInWithApple('Something went wrong...');
      }
    }
  }
}
