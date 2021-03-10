part of 'walletconnect_bloc.dart';

abstract class WalletConnectEvent extends Equatable {
  const WalletConnectEvent();

  @override
  List<Object> get props => [];
}

class ScanWC extends WalletConnectEvent {
  final String uri;

  ScanWC(this.uri);
}

class RequestWC extends WalletConnectEvent {
  final WCRequest request;

  RequestWC(this.request);
}

class ApproveWC extends WalletConnectEvent {}

class ConnectWC extends WalletConnectEvent {}

class DisconnectWC extends WalletConnectEvent {
  final String message;

  DisconnectWC(this.message);
}
