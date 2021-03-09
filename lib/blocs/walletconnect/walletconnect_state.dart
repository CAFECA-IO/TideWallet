part of 'walletconnect_bloc.dart';

enum WC_ERROR {
  URI
}

abstract class WalletConnectState extends Equatable {
  final bool connected;
  WalletConnectState(this.connected);
  
  @override
  List<Object> get props => [connected];
}

class WalletConnectInitial extends WalletConnectState {
  WalletConnectInitial() : super(false);
}

class WalletConnectLoaded extends WalletConnectState {
  WalletConnectLoaded() : super(false);
}

class WalletConnectConnecting extends WalletConnectState {
  WalletConnectConnecting() : super(false);
}

class WalletConnectToBeVerified extends WalletConnectState {
  WalletConnectToBeVerified() : super(false);
}

class WalletConnected extends WalletConnectState {
  WalletConnected(bool connected) : super(connected);
}

class WalletConnectError extends WalletConnectState {
  final WC_ERROR error;

  WalletConnectError(this.error) : super(false);

  @override
  List<Object> get props => [error];
}
