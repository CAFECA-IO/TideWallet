part of 'walletconnect_bloc.dart';

enum WC_ERROR {
  URI
}

abstract class WalletConnectState extends Equatable {
  const WalletConnectState();
  
  @override
  List<Object> get props => [];
}

class WalletconnectInitial extends WalletConnectState {}

class WalletconnectLoaded extends WalletConnectState {}

class WalletconnectError extends WalletConnectState {
  final WC_ERROR error;

  WalletconnectError(this.error);

  @override
  List<Object> get props => [error];
}
