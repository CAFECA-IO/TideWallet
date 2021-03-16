import 'dart:async';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tidewallet3/cores/signer.dart';
import 'package:tidewallet3/helpers/cryptor.dart';
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
  static const ACCOUNT _accountType = ACCOUNT.ETH;
  Currency _selected;

  WalletConnectBloc(this._accountRepo, this._txRepo)
      : super(WalletConnectInitial());

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
        final connection = Connector.parseUri(event.uri);
        _session = WCSession(
          key: connection.key,
          bridge: connection.bridge,
          peerId: connection.topic,
        );

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
        final chainId = event.request.params[0]['chainId'];
        final currencies = this._accountRepo.getAllCurrencies();
        _selected = currencies.firstWhere((c) => c.accountType == _accountType && c.chainId == chainId, orElse: () => currencies.firstWhere((c) =>c.accountType == _accountType));

        this._txRepo.setCurrency(_selected);
        _session.chainId = chainId;
        _session.networkId = chainId;
        String address = await getReceivingAddress();

        _session.accounts = [address];
        _connector.accounts = _session.accounts;
        yield _state.copyWith(
          status: WC_STATUS.WAITING,
          peer: _connector.peerMeta,
          accounts: _connector.accounts,
        );
      }

      if (event is ApproveWC) {
        _connector.approveSession(_session);
      }

      if (event is ConnectWC) {
        yield _state.copyWith(status: WC_STATUS.CONNECTED);
      }

      if (event is ReceiveWCEvent) {
        if (_state.currentEvent == null) {
          yield _state.copyWith(currentEvent: event.request);
        }
      }

      if (event is CancelRequest) {
        _connector.rejectRequest(WCReject.fromRequest(event.request));
        yield _state.copyWith(currentEvent: null);
      }
      if (event is ApproveRequest) {
        String reuslt;
        yield _state.copyWith(loading: true);

        switch (event.request.method) {
          case 'eth_sendTransaction':
            final param = event.request.params[0];

            Decimal amount = hexStringToDecimal(param['value']);
            Decimal gasPrice = hexStringToDecimal(param['gasPrice']);
            Decimal gasLimit = hexStringToDecimal(param['gas']);

            final txRes = await _txRepo.prepareTransaction(
              event.password,
              param['to'],
              amount,
              fee: gasPrice * gasLimit,
              gasPrice: gasPrice,
              gasLimit: gasLimit,
              message: param['data'],
            );

            List publishRes =
                await _txRepo.publishTransaction(txRes[0], txRes[1]);
            if (publishRes[0] == true) {
              reuslt = publishRes[1].txId;
            }

            break;
          case 'personal_sign':
            // TODO: Not Sure
            final key = await _txRepo.getPrivKey(event.password, 0, 0);

            // TODO:
            // final addressRequested = event.request.params[1];
            final lst =
                hex.decode(event.request.params[0].replaceAll('0x', ''));
            final data =
                Uint8List.fromList(Cryptor.keccak256round(lst, round: 1));
            final signature = Signer().sign(data, key);
            reuslt = '0x' +
                signature.r.toRadixString(16) +
                signature.s.toRadixString(16) +
                signature.v.toRadixString(16);
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

        if (reuslt == null) {
          _connector.rejectRequest(WCReject.fromRequest(event.request));

          yield _state.copyWith(currentEvent: null, error: WC_ERROR.SEND_TX);
        } else {
          _connector.approveRequest(
              WCApprove.fromRequest(event.request, result: reuslt));
          yield _state.copyWith(currentEvent: null);
        }
      }

      if (event is DisconnectWC) {
        if (_connector.connected == true) {
          _connector.killSession();
        }
        yield _state.copyWith(status: WC_STATUS.UNCONNECTED);
      }
    }
  }
}
