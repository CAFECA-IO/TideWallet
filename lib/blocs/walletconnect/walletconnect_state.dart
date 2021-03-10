part of 'walletconnect_bloc.dart';

enum WC_ERROR { URI }

enum WC_STATUS { CONNECTED, CONNECTING, WAITING, UNCONNECTED }

abstract class WalletConnectState extends Equatable {
  const WalletConnectState();
}

class WalletConnectInitial extends WalletConnectState {
  WalletConnectInitial();

  @override
  List<Object> get props => [];
}

class WalletConnectLoaded extends WalletConnectState {
  final WC_STATUS status;
  final PeerMeta peer;
  final List<String> accounts;
  final WCRequest currentEvent;
  // TODO
  final List<dynamic> records;
  WalletConnectLoaded({this.status, this.peer, this.accounts, this.records, this.currentEvent});

  @override
  List<Object> get props => [status, peer, accounts, records, currentEvent];

  WalletConnectLoaded copWith({
    WC_STATUS status,
    PeerMeta peer,
    List<String> peers,
    List<dynamic> records,
    List<String> accounts,
    WCRequest currentEvent
  }) {
    return WalletConnectLoaded(
      status: status ?? this.status,
      peer: peer ?? this.peer,
      accounts: accounts ?? this.accounts,
      records: records ?? this.records,
      currentEvent: currentEvent 
    );
  }
}

class WalletConnectError extends WalletConnectState {
  final WC_ERROR error;

  WalletConnectError(this.error) : super();

  @override
  List<Object> get props => [error];
}
