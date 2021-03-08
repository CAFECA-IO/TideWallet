import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

import '../../cores/walletconnect/core.dart';
import '../../constants/account_config.dart';
part 'walletconnect_event.dart';
part 'walletconnect_state.dart';

class WalletConnectBloc extends Bloc<WalletConnectEvent, WalletConnectState> {
  WalletConnectBloc() : super(WalletConnectInitial());
  Connector _connector;

  @override
  Stream<Transition<WalletConnectEvent, WalletConnectState>> transformEvents(
      Stream<WalletConnectEvent> events, transitionFn) {
    return events
        .throttleTime(const Duration(milliseconds: 500))
        .switchMap((transitionFn));
  }

  @override
  Stream<WalletConnectState> mapEventToState(
    WalletConnectEvent event,
  ) async* {
    if (event is ScanWC) {
      if (state is WalletConnectInitial || state is WalletConnectError) {
        final connection = Connector.parseUri(event.uri);

        if (connection == null) {
          yield WalletConnectError(WC_ERROR.URI);
        } else {
          _connector = Connector(connection);

          yield WalletConnectLoaded();
        }
      }
    }

    if (event is ApproveWC) {
      int id = USE_NETWORK == NETWORK.MAINNET ? 1 : 3; // Ropsten
      _connector.approveSession(WCSession(chainId: id, networkId: id));
    }
  }
}
