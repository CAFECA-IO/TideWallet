part of 'mnemonic_bloc.dart';

enum MNEMONIC_ERROR { NONE, MNEMONIC_INVALID, PASSWORD_NOT_MATCH, LOGIN }

abstract class MnemonicState extends Equatable {
  const MnemonicState();

  @override
  List<Object> get props => [];
}

class MnemonicInitial extends MnemonicState {}

class MnemonicTyping extends MnemonicState {
  final String mnemonic;
  final String passphrase;
  final String rePassphrase;
  final MNEMONIC_ERROR error;

  MnemonicTyping(
      {this.mnemonic = '',
      this.passphrase = '',
      this.rePassphrase = '',
      this.error = MNEMONIC_ERROR.NONE});

  MnemonicState copyWith({mnemonic, passphrase, rePassphrase, error}) =>
      MnemonicTyping(
        mnemonic: mnemonic ?? this.mnemonic,
        passphrase: passphrase ?? this.passphrase,
        rePassphrase: rePassphrase ?? this.rePassphrase,
        error: error ?? this.error,
      );

  @override
  List<Object> get props => [mnemonic, passphrase, rePassphrase, error];
}

class MnemonicLoading extends MnemonicState {}

class MnemonicSuccess extends MnemonicState {
  final String userIndentifier;
  final Uint8List seed;

  MnemonicSuccess(this.userIndentifier, this.seed);
}
