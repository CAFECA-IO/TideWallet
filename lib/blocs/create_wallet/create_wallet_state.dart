part of 'create_wallet_bloc.dart';

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
  final String errorMsg;

  bool get isEqualed => password == rePassword;

  CreateWalletCheck({
    this.name = '',
    this.password,
    this.rePassword,
    this.rules,
    this.errorMsg,
  });

  CreateWalletState copyWith({name, password, rePassword, rules, rePasswordValid}) {
    return CreateWalletCheck(
      name: name ?? this.name,
      password: password ?? this.password,
      rePassword: rePassword ?? this.rePassword,
      rules: rules ?? this.rules,
      errorMsg: rePasswordValid ?? this.errorMsg,
    );
  }

  @override
  List<Object> get props => [password, rePassword];
}
