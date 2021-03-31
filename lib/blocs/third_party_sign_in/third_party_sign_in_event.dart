part of 'third_party_sign_in_bloc.dart';

abstract class ThirdPartySignInEvent extends Equatable {
  const ThirdPartySignInEvent();

  @override
  List<Object> get props => [];
}

class SignInWithApple extends ThirdPartySignInEvent {
  SignInWithApple();
}
