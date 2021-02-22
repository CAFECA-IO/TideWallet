part of 'update_password_bloc.dart';

enum UpdateFormError { wrongPassword, passwordInvalid, passwordNotMatch, none }

@immutable
abstract class UpdatePasswordState extends Equatable {}

class UpdatePasswordInitial extends UpdatePasswordState {
  @override
  List<Object> get props => [];
}

class UpdatePasswordStateCheck extends UpdatePasswordState {
  final String currentPassword;
  final String password;
  final String rePassword;
  final List<bool> rules;
  final UpdateFormError error;

  bool get isEqualed => password == rePassword;

  static const defaultValid = [false, false, false, false];

  UpdatePasswordStateCheck({
    this.currentPassword = '',
    this.password = '',
    this.rePassword = '',
    this.rules = defaultValid,
    this.error,
  });

  UpdatePasswordState copyWith({
    String currentPassword,
    String password,
    String rePassword,
    List<bool> rules,
    UpdateFormError error,
  }) {
    return UpdatePasswordStateCheck(
      currentPassword: currentPassword ?? this.currentPassword,
      password: password ?? this.password,
      rePassword: rePassword ?? this.rePassword,
      rules: rules ?? this.rules,
      error: error,
    );
  }

  @override
  List<Object> get props =>
      [currentPassword, password, rePassword, rules, error];
}

class PasswordUpdating extends UpdatePasswordState {
  @override
  List<Object> get props => [];
}

class PasswordUpdated extends UpdatePasswordState {
  @override
  List<Object> get props => [];
}

class PasswordUpdateFail extends UpdatePasswordState {
  @override
  List<Object> get props => [];
}
