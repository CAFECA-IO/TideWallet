import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tidewallet3/helpers/utils.dart';

import '../../helpers/logger.dart';
import '../../models/account.model.dart';
import '../../repositories/account_repository.dart';
import '../../repositories/transaction_repository.dart';
import '../../cores/walletconnect/core.dart';
import '../../constants/account_config.dart';
part 'walletconnect_event.dart';
part 'walletconnect_state.dart';

class WalletConnectBloc extends Bloc<WalletConnectEvent, WalletConnectState> {
  Connector _connector;
  WCSession _session;
  TransactionRepository _txRepo;
  AccountRepository _accountRepo;
  ACCOUNT _accountType = ACCOUNT.ETH;
  Currency _selected;

  WalletConnectBloc(this._accountRepo, this._txRepo)
      : super(WalletConnectInitial()) {
    final currencies = this._accountRepo.getCurrencies(_accountType);
    _selected = currencies[0];

    this._txRepo.setCurrency(_selected);
  }

  getReceivingAddress() => _txRepo.getReceivingAddress();

  get currency => this._selected;

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
        int id = _selected.chainId;
        String address = await getReceivingAddress();

        final connection = Connector.parseUri(event.uri);
        _session = WCSession(
            chainId: id,
            networkId: id,
            key: connection.key,
            bridge: connection.bridge,
            peerId: connection.topic,
            accounts: [address]);

        if (connection == null) {
          yield WalletConnectError(WC_ERROR.URI);
        } else {
          _connector = Connector(ConnectorOpts(session: _session));
          this.subscribeToEvents();

          yield WalletConnectLoaded(status: WC_STATUS.CONNECTING);
        }
      }
    }

    if (state is WalletConnectLoaded) {

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
        String reuslt;

        switch (event.request.method) {
          case 'eth_sendTransaction':
            // TODO:
            // final key = await _txRepo.getPrivKey(event.password, 0, 0);
            final param = event.request.params[0];
            print(_txRepo);
            print('000000000 ${param}');
            Decimal amount = hexStringToDecimal(param['value']);
            Decimal gasPrice = hexStringToDecimal(param['gasPrice']);
            Decimal gasLimit = hexStringToDecimal(param['gas']);

            final txRes = await _txRepo.prepareTransaction(
              event.password,
              param['to'],
              amount,
              fee: gasPrice * gasLimit,
              message: param['data'],
            );

            reuslt = txRes[0].txid;

            break;
          case 'personal_sign':
            // TODO:
            await Future.delayed(Duration(seconds: 1));
            reuslt =
                '0x1e6bf8af9b345731be3d89f46f344bac0819d4c40cf419546ffc62f59bc86d251821db81350c5f5a5e0773969840c5b097e0d6cd0eeb7c6ae68d3ebaac1290531c';
            break;


          case 'eth_signTypedData':
            // TODO:
            await Future.delayed(Duration(seconds: 1));
            reuslt =
                '0x88daf041984dfbc4e2da1cf4e4f1b3e205c6409052c749a7890ecf248855a4bd7fd4e908db3cd3593515bebf971c5b448bf3142b34999cb3963e6e33e0a0d50d1c';
            break;
          default:
            throw (ERROR_MISSING.METHOD);
        }

        _connector
            .approveRequest(WCApprove.fromRequest(event.request, result: reuslt));
        yield _state.copWith(currentEvent: null);
      }

      if (event is DisconnectWC) {
        if (_connector.connected == true) {
          _connector.killSession();
        }
        yield _state.copWith(status: WC_STATUS.UNCONNECTED);
      }
    }
  }
}
