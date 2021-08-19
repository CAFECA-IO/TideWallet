import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

import '../../cores/paper_wallet.dart';
import '../../cores/walletconnect/core.dart';
import '../../cores/typeddata.dart';
import '../../cores/signer.dart';
import '../../repositories/account_repository.dart';
import '../../repositories/transaction_repository.dart';
import '../../models/transaction.model.dart';
import '../../models/account.model.dart';
import '../../helpers/cryptor.dart';
import '../../helpers/utils.dart';
import '../../helpers/logger.dart';
import '../../constants/account_config.dart';
part 'walletconnect_event.dart';
part 'walletconnect_state.dart';

class WalletConnectBloc extends Bloc<WalletConnectEvent, WalletConnectState> {
  static const ACCOUNT _accountType = ACCOUNT.ETH;
  TransactionRepository _txRepo;
  AccountRepository _accountRepo;

  Connector? _connector;
  Connector get connector => this._connector!;
  set connector(Connector connector) => this._connector = connector;

  WCSession? _session;
  WCSession get session => this._session!;
  set session(WCSession session) => this._session = session;

  Account? _selected;
  Account get selected => this._selected!;
  set selected(Account account) => this._selected = account;

  Map<TransactionPriority, Decimal>? _gasPrice;
  Map<TransactionPriority, Decimal> get gasPrice => this._gasPrice!;
  set gasPrice(Map<TransactionPriority, Decimal> gasPrice) =>
      this._gasPrice = gasPrice;

  WalletConnectBloc(this._accountRepo, this._txRepo)
      : super(WalletConnectInitial());

  getReceivingAddress() => _txRepo.getReceivingAddress();

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
    connector.killSession();
    return super.close();
  }

  subscribeToEvents() {
    connector.onEvt('connect', (Map data) {
      this.add(ConnectWC());
    });

    connector.onEvt('session_request', (WCRequest req) {
      this.add(RequestWC(req));
    });

    connector.onEvt('eth_sendTransaction', (WCRequest req) {
      this.add(ReceiveWCEvent(req));
    });
    connector.onEvt('personal_sign', (WCRequest req) {
      this.add(ReceiveWCEvent(req));
    });
    connector.onEvt('eth_signTypedData', (WCRequest req) {
      Log.debug('Get eth_signTypedData on BLOC');
      this.add(ReceiveWCEvent(req));
    });
    connector.onEvt('disconnect', (String req) {
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
        session = WCSession(
          key: connection.key,
          bridge: connection.bridge,
          peerId: connection.topic,
        );

        connector = Connector(ConnectorOpts(session: session));
        this.subscribeToEvents();

        yield WalletConnectLoaded(status: WC_STATUS.CONNECTING);
      }
    }

    if (state is WalletConnectLoaded) {
      WalletConnectLoaded _state = state as WalletConnectLoaded;

      if (event is RequestWC) {
        int? chainId = event.request.params?[0]['chainId'];
        if (chainId == null) chainId = 1;
        final currencies = this._accountRepo.accountList;
        selected = currencies.firstWhere(
            (c) => c.accountType == _accountType && c.chainId == chainId,
            orElse: () =>
                currencies.firstWhere((c) => c.accountType == _accountType));

        print('Connect Chain ID : ${selected.chainId}');

        // check to use the right chain
        // Log.info('*** chainId $chainId ${selected.network} __ ${selected.chainId}');

        this._txRepo.account = selected;
        session.chainId = chainId;
        session.networkId = chainId;
        String address = await getReceivingAddress();

        session.accounts = [address];
        connector.accounts = session.accounts!;
        yield _state.copyWith(
          status: WC_STATUS.WAITING,
          peer: connector.peerMeta,
          accounts: connector.accounts,
        );
      }

      // if (event is ApproveWC) {
      //   connector.approveSession(session);
      //   gasPrice = await _txRepo.getGasPrice();
      // }

      if (event is ConnectWC) {
        yield _state.copyWith(status: WC_STATUS.CONNECTED);
      }

      if (event is ReceiveWCEvent) {
        if (_state.currentEvent == null) {
          yield _state.copyWith(currentEvent: event.request);
        }
      }

      if (event is CancelRequest) {
        connector.rejectRequest(WCReject.fromRequest(event.request));
        yield _state.copyWith(currentEvent: null);
      }
      if (event is ApproveRequest) {
        String? result;
        yield _state.copyWith(loading: true);

        switch (event.request.method) {
          case 'eth_sendTransaction':
            // final param = event.request.params![0];

            // Decimal amount = hexStringToDecimal(param['value']) /
            //     Decimal.fromInt(pow(10, 18) as int);
            // Decimal gasPrice = hexStringToDecimal(param['gasPrice']) /
            //     Decimal.fromInt(pow(10, 18) as int);
            // Decimal gasLimit = hexStringToDecimal(param['gas']);

            // final txRes = await _txRepo.prepareTransaction(
            //   param['to'],
            //   amount,
            //   fee: gasPrice * gasLimit,
            //   gasPrice: gasPrice,
            //   gasLimit: gasLimit,
            //   message: param['data'],
            // );

            // List publishRes =
            //     await _txRepo.publishTransaction(txRes[0], txRes[1]);
            // if (publishRes[0] == true) {
            //   result = publishRes[1].txId;
            // }

            break;
          case 'personal_sign':
            // TODO:
            // final addressRequested = event.request.params[1];
            // final lst =
            //     hex.decode(event.request.params![0].replaceAll('0x', ''));
            // final data = Cryptor.keccak256round(lst, round: 1);
            // final MsgSignature signature = await PaperWalletCore()
            //     .sign(data: data, changeIndex: 0, keyIndex: 0);
            // result = '0x' +
            //     signature.r.toRadixString(16) +
            //     signature.s.toRadixString(16) +
            //     signature.v.toRadixString(16);
            break;

          case 'eth_signTypedData':
            // final data = TypedData.sign(json.decode(event.request.params![1]));
            // final MsgSignature signature = await PaperWalletCore()
            //     .sign(data: data, changeIndex: 0, keyIndex: 0);
            // result = result = '0x' +
            //     signature.r.toRadixString(16) +
            //     signature.s.toRadixString(16) +
            //     signature.v.toRadixString(16);
            break;
          default:
            throw (ERROR_MISSING.METHOD);
        }

        if (result == null) {
          connector.rejectRequest(WCReject.fromRequest(event.request));

          yield _state.copyWith(currentEvent: null, error: WC_ERROR.SEND_TX);
        } else {
          connector.approveRequest(
              WCApprove.fromRequest(event.request, result: result));
          yield _state.copyWith(currentEvent: null);
        }
      }

      if (event is DisconnectWC) {
        if (connector.connected == true) {
          connector.killSession();
        }
        yield _state.copyWith(status: WC_STATUS.UNCONNECTED);
      }
    }
  }
}
