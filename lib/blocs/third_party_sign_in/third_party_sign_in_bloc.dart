import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../repositories/third_party_sign_in_repository.dart';

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
    if (!(state is ThirdPartySignInInitial)) yield ThirdPartySignInInitial();
    if (event is SignInWithApple) {
      List response = await this._repo.signInWithAppleId();
      bool success = response[0];
      if (success) {
        String userIndentifier = response[1];
        yield SignedInWithThirdParty(userIndentifier);
      } else {
        yield FailedSignInWithThirdParty(response[1]);
      }
    }
    if (event is SignInWithGoogle) {
      yield SigningInWithThirdParty();
      List response = await this._repo.signInWithGoogleId();
      bool success = response[0];
      if (success) {
        String userIndentifier = response[1];
        yield SignedInWithThirdParty(userIndentifier);
      } else {
        String message = response[1];
        yield FailedSignInWithThirdParty(message);
      }
    }
  }
}
