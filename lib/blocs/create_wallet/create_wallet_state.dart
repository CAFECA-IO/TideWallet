part of 'create_wallet_bloc.dart';

enum CreateFormError { nameEmpty, passwordInvalid, passwordNotMatch, none }

@immutable
abstract class CreateWalletState extends Equatable {}

class CreateWalletInitial extends CreateWalletState {
  @override
  List<Object> get props => [];
}

class CreateWalletCheck extends CreateWalletState {
  final String name;
  final String password;
  final String rePassword;
  final List<bool> rules;
  final CreateFormError error;

  bool get isEqualed => password == rePassword;

  static const defaultValid = [false, false, false, false];

  CreateWalletCheck({
    this.name = '',
    this.password = '',
    this.rePassword = '',
    this.rules = defaultValid,
    this.error = CreateFormError.none,
  });

  CreateWalletState copyWith({
    String? name,
    String? password,
    String? rePassword,
    List<bool>? rules,
    CreateFormError? error,
  }) {
    return CreateWalletCheck(
      name: name ?? this.name,
      password: password ?? this.password,
      rePassword: rePassword ?? this.rePassword,
      rules: rules ?? this.rules,
      error: error ?? this.error,
    );
  }

  @override
  List<Object> get props => [name, password, rePassword, rules, error];
}
