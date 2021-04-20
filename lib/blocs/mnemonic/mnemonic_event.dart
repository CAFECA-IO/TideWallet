part of 'mnemonic_bloc.dart';

abstract class MnemonicEvent extends Equatable {
  const MnemonicEvent();

  @override
  List<Object> get props => [];
}

class InputMnemo extends MnemonicEvent {
  final String text;

  InputMnemo(this.text);
}

class InputMnemoPassword extends MnemonicEvent {
  final String password;

  InputMnemoPassword(this.password);
}

class InputMnemoRePassword extends MnemonicEvent {
  final String password;

  InputMnemoRePassword(this.password);
}

class SubmitMnemonic extends MnemonicEvent {}