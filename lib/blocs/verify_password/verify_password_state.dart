part of 'verify_password_bloc.dart';

abstract class VerifyPasswordState extends Equatable {
  const VerifyPasswordState();

  @override
  List<Object> get props => [];
}

class VerifyPasswordInitial extends VerifyPasswordState {}

class VerifyingPassword extends VerifyPasswordState {}

class PasswordVerified extends VerifyPasswordState {
  final String password;
  PasswordVerified(this.password);
}

class PasswordInvalid extends VerifyPasswordState {}
