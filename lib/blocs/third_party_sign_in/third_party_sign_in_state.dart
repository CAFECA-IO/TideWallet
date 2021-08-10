part of 'third_party_sign_in_bloc.dart';

abstract class ThirdPartySignInState extends Equatable {
  const ThirdPartySignInState();

  @override
  List<Object> get props => [];
}

class ThirdPartySignInInitial extends ThirdPartySignInState {}

class SignedInWithThirdParty extends ThirdPartySignInState {
  final String userIndentifier;
  SignedInWithThirdParty(this.userIndentifier);
  @override
  List<Object> get props => [userIndentifier];
}

class SigningInWithThirdParty extends ThirdPartySignInState {
  SigningInWithThirdParty();
  @override
  List<Object> get props => [];
}

class FailedSignInWithThirdParty extends ThirdPartySignInState {
  final String? message;
  FailedSignInWithThirdParty(this.message);
}

class CancelledSignInWithThirdParty extends ThirdPartySignInState {
  CancelledSignInWithThirdParty();
}
