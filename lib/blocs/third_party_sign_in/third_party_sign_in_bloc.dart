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
    if (event is SignInWithApple) {
      try {
        String userIndentifier = await this._repo.signInWithAppleId();
        if (userIndentifier != null)
          yield SignedInWithApple(userIndentifier);
        else
          yield FailedSignInWithApple();
      } catch (e) {
        yield FailedSignInWithApple();
      }
    }
  }
}
