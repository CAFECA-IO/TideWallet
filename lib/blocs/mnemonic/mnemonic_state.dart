part of 'mnemonic_bloc.dart';

enum MNEMONIC_ERROR { NONE, MNEMONIC_INVALID, PASSWORD_NOT_MATCH }

abstract class MnemonicState extends Equatable {
  const MnemonicState();

  @override
  List<Object> get props => [];
}

class MnemonicInitial extends MnemonicState {}

class MnemonicTyping extends MnemonicState {
  final String mnemonic;
  final String password;
  final String rePassword;
  final MNEMONIC_ERROR error;

  MnemonicTyping({this.mnemonic = '', this.password = '', this.rePassword = '', this.error = MNEMONIC_ERROR.NONE});

  copyWith({mnemonic, password, rePassword, error}) => MnemonicTyping(
        mnemonic: mnemonic ?? this.mnemonic,
        password: password ?? this.password,
        rePassword: rePassword ?? this.rePassword,
        error: error ?? this.error,
      );

  @override
  List<Object> get props => [mnemonic, password, rePassword, error];
}

class MnemonicLoading extends MnemonicState {}

class MnemonicSuccess extends MnemonicState {
  final String seed;

  MnemonicSuccess(this.seed);
}
