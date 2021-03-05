part of 'walletconnect_bloc.dart';

enum WC_ERROR {
  URI
}

abstract class WalletConnectState extends Equatable {
  const WalletConnectState();
  
  @override
  List<Object> get props => [];
}

class WalletConnectInitial extends WalletConnectState {}

class WalletConnectLoaded extends WalletConnectState {}

class WalletConnectApproved extends WalletConnectState {}

class WalletConnectError extends WalletConnectState {
  final WC_ERROR error;

  WalletConnectError(this.error);

  @override
  List<Object> get props => [error];
}
