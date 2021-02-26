part of 'verify_password_bloc.dart';

abstract class VerifyPasswordEvent extends Equatable {
  const VerifyPasswordEvent();

  @override
  List<Object> get props => [];
}

class VerifyPassword extends VerifyPasswordEvent {
  final String password;
  VerifyPassword(this.password);
}
