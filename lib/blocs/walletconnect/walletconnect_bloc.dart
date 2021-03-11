import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tidewallet3/helpers/logger.dart';

import '../../cores/walletconnect/core.dart';
import '../../constants/account_config.dart';
part 'walletconnect_event.dart';
part 'walletconnect_state.dart';

class WalletConnectBloc extends Bloc<WalletConnectEvent, WalletConnectState> {
  WalletConnectBloc() : super(WalletConnectInitial());
  Connector _connector;
  WCSession _session;

  // TODO
  getReceivingAddress() => '0x9c93C3Be6Abdc1DBf0f35F1e57a2CCfEA92A8e84';

  @override
  Stream<Transition<WalletConnectEvent, WalletConnectState>> transformEvents(
      Stream<WalletConnectEvent> events, transitionFn) {
    final nonThrottleStream = events.where((event) => event is! ScanWC);

    final throttleStream = events
        .where((event) => event is ScanWC)
        .throttleTime(const Duration(milliseconds: 500));

    return super.transformEvents(
        MergeStream([nonThrottleStream, throttleStream]), transitionFn);
  }

  @override
  Future<void> close() {
    _connector?.killSession();
    return super.close();
  }

  subscribeToEvents() {
    _connector.onEvt('connect', (Map data) {
      this.add(ConnectWC());
    });

    _connector.onEvt('session_request', (WCRequest req) {
      this.add(RequestWC(req));
    });

    _connector.onEvt('eth_sendTransaction', (WCRequest req) {
      this.add(ReceiveWCEvent(req));
    });
    _connector.onEvt('personal_sign', (WCRequest req) {
      Log.debug('Get personal_sign on BLOC');
      this.add(ReceiveWCEvent(req));
    });
    _connector.onEvt('eth_signTypedData', (WCRequest req) {
      Log.debug('Get eth_signTypedData on BLOC');
      this.add(ReceiveWCEvent(req));
    });
    _connector.onEvt('disconnect', (String req) {
      this.add(DisconnectWC('Receive Disconnet'));
    });
  }

  @override
  Stream<WalletConnectState> mapEventToState(
    WalletConnectEvent event,
  ) async* {
    if (event is ScanWC) {
      if (state is WalletConnectInitial || state is WalletConnectError) {
        int id = USE_NETWORK == NETWORK.MAINNET ? 1 : 3; // Ropsten

        final connection = Connector.parseUri(event.uri);
        _session = WCSession(
            chainId: id,
            networkId: id,
            key: connection.key,
            bridge: connection.bridge,
            peerId: connection.topic,
            accounts: [getReceivingAddress()]);

        if (connection == null) {
          yield WalletConnectError(WC_ERROR.URI);
        } else {
          _connector = Connector(ConnectorOpts(session: _session));
          this.subscribeToEvents();

          yield WalletConnectLoaded(status: WC_STATUS.CONNECTING);
        }
      }
    }
    WalletConnectLoaded _state = state;

    if (event is RequestWC) {
      yield _state.copWith(
        status: WC_STATUS.WAITING,
        peer: _connector.peerMeta,
        accounts: _connector.accounts,
      );
    }

    if (event is ApproveWC) {
      _connector.approveSession(_session);
    }

    if (event is ConnectWC) {
      yield _state.copWith(status: WC_STATUS.CONNECTED);
    }

    if (event is ReceiveWCEvent) {
      if (_state.currentEvent == null) {
        yield _state.copWith(currentEvent: event.request);
      }
    }

    if (event is CancelRequest) {
      _connector.rejectRequest(WCReject.fromRequest(event.request));
      yield _state.copWith(currentEvent: null);
    }

    if (event is ApproveRequest) {
      _connector.approveRequest(WCApprove.fromRequest(event.request, result: event.result));
    }

    if (event is DisconnectWC) {
      if (_connector.connected == true) {
        _connector.killSession();
      }
      yield _state.copWith(status: WC_STATUS.UNCONNECTED);
    }

  }
}
