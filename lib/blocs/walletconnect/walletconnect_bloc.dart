import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

import '../../helpers/logger.dart';
import '../../models/account.model.dart';
import '../../repositories/account_repository.dart';
import '../../repositories/transaction_repository.dart';
import '../../cores/walletconnect/core.dart';
import '../../constants/account_config.dart';
import '../../cores/typeddata.dart';
import '../../cores/signer.dart';
import '../../helpers/cryptor.dart';
import '../../helpers/utils.dart';
import '../../models/transaction.model.dart';
part 'walletconnect_event.dart';
part 'walletconnect_state.dart';

class WalletConnectBloc extends Bloc<WalletConnectEvent, WalletConnectState> {
  late Connector _connector;
  late WCSession _session;
  late TransactionRepository _txRepo;
  late AccountRepository _accountRepo;
  static const ACCOUNT _accountType = ACCOUNT.ETH;
  late Currency _selected;
  late Map<TransactionPriority, Decimal> _gasPrice;

  WalletConnectBloc(this._accountRepo, this._txRepo)
      : super(WalletConnectInitial());

  getReceivingAddress() => _txRepo.getReceivingAddress();

  Currency get currency => this._selected;
  Map<TransactionPriority, Decimal> get gasPrice => this._gasPrice;

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
    _connector.killSession();
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
        late ConnectionEl connection;
        try {
          connection = Connector.parseUri(event.uri);
        } catch (e) {
          yield WalletConnectError(WC_ERROR.URI);
        }
        _session = WCSession(
          key: connection.key,
          bridge: connection.bridge,
          peerId: connection.topic,
        );

        _connector = Connector(ConnectorOpts(session: _session));
        this.subscribeToEvents();

        yield WalletConnectLoaded(status: WC_STATUS.CONNECTING);
      }
    }

    if (state is WalletConnectLoaded) {
      WalletConnectLoaded _state = state as WalletConnectLoaded;

      if (event is RequestWC) {
        int? chainId = event.request.params?[0]['chainId'];
        if (chainId == null) chainId = 1;
        final currencies = this._accountRepo.getAllCurrencies();
        _selected = currencies.firstWhere(
            (c) => c.accountType == _accountType && c.chainId == chainId,
            orElse: () =>
                currencies.firstWhere((c) => c.accountType == _accountType));

        print('Connect Chain ID : ${_selected.chainId}');

        // check to use the right chain
        // Log.info('*** chainId $chainId ${_selected.network} __ ${_selected.chainId}');

        this._txRepo.setCurrency(_selected);
        _session.chainId = chainId;
        _session.networkId = chainId;
        String address = await getReceivingAddress();

        _session.accounts = [address];
        _connector.accounts = _session.accounts!;
        yield _state.copyWith(
          status: WC_STATUS.WAITING,
          peer: _connector.peerMeta,
          accounts: _connector.accounts,
        );
      }

      if (event is ApproveWC) {
        _connector.approveSession(_session);
        this._gasPrice = await _txRepo.getGasPrice();
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
        String? result;
        yield _state.copyWith(loading: true);

        switch (event.request.method) {
          case 'eth_sendTransaction':
            final param = event.request.params![0];

            Decimal amount = hexStringToDecimal(param['value']) /
                Decimal.fromInt(pow(10, 18) as int);
            Decimal gasPrice = hexStringToDecimal(param['gasPrice']) /
                Decimal.fromInt(pow(10, 18) as int);
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
              result = publishRes[1].txId;
            }

            break;
          case 'personal_sign':
            final key = await _txRepo.getPrivKey(event.password, 0, 0);

            // TODO:
            // final addressRequested = event.request.params[1];
            final lst =
                hex.decode(event.request.params![0].replaceAll('0x', ''));
            final data = Cryptor.keccak256round(lst, round: 1);
            final signature = Signer().sign(data, key);
            result = '0x' +
                signature.r.toRadixString(16) +
                signature.s.toRadixString(16) +
                signature.v.toRadixString(16);
            break;

          case 'eth_signTypedData':
            final key = await _txRepo.getPrivKey(event.password, 0, 0);
            final data = json.decode(event.request.params![1]);
            result = TypedData.signTypedData_v4(key, data);
            break;
          default:
            throw (ERROR_MISSING.METHOD);
        }

        if (result == null) {
          _connector.rejectRequest(WCReject.fromRequest(event.request));

          yield _state.copyWith(currentEvent: null, error: WC_ERROR.SEND_TX);
        } else {
          _connector.approveRequest(
              WCApprove.fromRequest(event.request, result: result));
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
