part of 'create_wallet_bloc.dart';

@immutable
abstract class CreateWalletEvent {}

class InputPassword extends CreateWalletEvent {
  final String password;

  InputPassword(this.password);
}

class InputRePassword extends CreateWalletEvent {
  final String password;

  InputRePassword(this.password);
}

class SubmitCreateWallet extends CreateWalletEvent {}