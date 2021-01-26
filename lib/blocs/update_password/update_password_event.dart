part of 'update_password_bloc.dart';

@immutable
abstract class UpdatePasswordEvent {}

class InputWalletCurrentPassword extends UpdatePasswordEvent {
  final String currentPassword;

  InputWalletCurrentPassword(this.currentPassword);
}

class InputPassword extends UpdatePasswordEvent {
  final String password;

  InputPassword(this.password);
}

class InputRePassword extends UpdatePasswordEvent {
  final String password;

  InputRePassword(this.password);
}

class SubmitUpdatePassword extends UpdatePasswordEvent {}

class CleanUpdatePassword extends UpdatePasswordEvent {}
