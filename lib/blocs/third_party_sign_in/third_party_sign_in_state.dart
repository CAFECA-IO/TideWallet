part of 'third_party_sign_in_bloc.dart';

abstract class ThirdPartySignInState extends Equatable {
  const ThirdPartySignInState();

  @override
  List<Object> get props => [];
}

class ThirdPartySignInInitial extends ThirdPartySignInState {}

class SignedInWithApple extends ThirdPartySignInState {
  final String userIndentifier;
  SignedInWithApple(this.userIndentifier);
  @override
  List<Object> get props => [userIndentifier];
}

class FailedSignInWithApple extends ThirdPartySignInState {
  FailedSignInWithApple();
}
