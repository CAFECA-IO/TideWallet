import 'dart:async';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:decimal/decimal.dart';

import 'account_service_decorator.dart';
import 'account_service.dart';

import '../models/account.model.dart';
import '../models/transaction.model.dart';
import '../models/api_response.mode.dart';
import '../constants/account_config.dart';
import '../constants/endpoint.dart';
import '../helpers/logger.dart';
import '../helpers/http_agent.dart';
import '../helpers/utils.dart';
import '../helpers/cryptor.dart';
import '../helpers/rlp.dart' as rlp;
import '../helpers/converter.dart';

import '../cores/account.dart';
import '../database/db_operator.dart';
import '../database/entity/account.dart';
import '../database/entity/currency.dart';

class EthereumService extends AccountServiceDecorator {
  EthereumService(AccountService service) : super(service) {
    this.base = ACCOUNT.ETH;
    this.syncInterval = 15000;
    // this.path = "m/44'/60'/0'";
  }
  String? _address;
  Map<TransactionPriority, Decimal>? _fee;
  int? _gasLimit;
  int? _feeTimestamp;
  int _nonce = 0;

  String get address => this._address!;
  Map<TransactionPriority, Decimal> get fee => this._fee!;
  int get gasLimit => this._gasLimit!;
  int get feeTimestamp => this._feeTimestamp!;
  int get nonce => this._nonce;

  set address(String address) => this._address = address;
  set fee(Map<TransactionPriority, Decimal> fee) => this._fee = fee;
  set gasLimit(int gasLimit) => this._gasLimit = gasLimit;
  set feeTimestamp(int feeTimestamp) => this._feeTimestamp = feeTimestamp;
  set nonce(int nonce) => this._nonce = nonce;

  @override
  void init(String id, ACCOUNT base, {int? interval}) {
    Log.eth('ETH Service Init');
    this.service.init(id, base, interval: this.syncInterval);
  }

  @override
  Future start() async {
    await this.service.start();

    this.synchro();

    this.service.timer =
        Timer.periodic(Duration(milliseconds: this.syncInterval), (_) {
      synchro();
    });
  }

  @override
  void stop() {
    this.service.stop();
  }

  static Future<Token> getTokeninfo(String blockchainId, String address) async {
    Future.delayed(Duration(milliseconds: 1000));
    APIResponse res = await HTTPAgent()
        .get(Endpoint.url + '/blockchain/$blockchainId/contract/$address');

    if (res.data != null && res.success) {
      Log.debug('Token res.data: ${res.data}');
      Token _token = Token(
          symbol: res.data['symbol'],
          name: res.data['name'],
          decimal: res.data['decimal'],
          imgUrl: res.data['imageUrl'],
          description: res.data['description'],
          contract: res.data['contract'],
          totalSupply: res.data['total_supply']);
      return _token;
    } else {
      throw Exception(res.message);
    }
  }

  Future<bool> addToken(DisplayToken token) async {
    APIResponse res = await HTTPAgent().post(
        Endpoint.url +
            '/wallet/blockchain/${token.blockchainId}/contract/${token.contract}',
        {});
    if (res.success == false) return false;

    try {
      String id = res.data['token_id'];
      APIResponse updateRes = await HTTPAgent()
          .get(Endpoint.url + '/wallet/account/${this.service.shareAccountId}');

      if (updateRes.success) {
        final acc = updateRes.data;
        List tks = [acc] + acc['tokens'];
        final index = tks.indexWhere((token) => token['token_id'] == id);

        await DBOperator().currencyDao.insertCurrency(
              CurrencyEntity.fromJson(
                {...tks[index], 'icon': token.icon, 'currency_id': id},
              ),
            );
        Log.info(id);

        final v = AccountEntity.fromAccountJson(
            tks[index],
            this.service.shareAccountId,
            AccountCore().accounts[this.service.shareAccountId]![0].userId);

        await DBOperator().accountDao.insertAccount(v);

        List<JoinAccount> jcs = await DBOperator()
            .accountDao
            .findJoinedAccountsByShareAccountId(this.service.shareAccountId);

        List<Account> cs = jcs
            .map((c) =>
                Account.fromJoinAccount(c).copyWith(accountType: this.base))
            .toList();

        AccountMessage msg =
            AccountMessage(evt: ACCOUNT_EVT.OnUpdateAccount, value: cs[0]);
        AccountCore().accounts[this.service.shareAccountId] = cs;

        AccountMessage currMsg = AccountMessage(
            evt: ACCOUNT_EVT.OnUpdateAccount,
            value: {
              "accounts": AccountCore().accounts[this.service.shareAccountId]
            });

        AccountCore().messenger.add(msg);
        AccountCore().messenger.add(currMsg);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      Log.error(e);
      throw Exception(e);
    }
  }

  String tokenTxMessage({
    String? to,
    String? amount,
    required int decimals,
    String? message,
  }) {
    List<int> erc20Func = Cryptor.keccak256round(
        utf8.encode('transfer(address,uint256)'),
        round: 1);
    message = '0x' +
        hex.encode(erc20Func.take(4).toList() +
            hex.decode((to ?? "").substring(2).padLeft(64, '0')) +
            hex.decode(hex
                .encode(encodeBigInt(BigInt.parse(
                    Converter.toCurrencySmallestUnit(
                            Decimal.parse(amount ?? "0"), decimals)
                        .toString())))
                .padLeft(64, '0')) +
            rlp.toBuffer(message));
    return message;
  }

  Future<Decimal> estimateGasLimit(String blockchainId, String from, String to,
      String amount, String message) async {
    if (message == '0x' && this._gasLimit != null)
      return Decimal.fromInt(this._gasLimit!);
    else {
      Map<String, dynamic> payload = {
        "fromAddress": from,
        "toAddress": to,
        "value": amount,
        "data": message
      };
      APIResponse response = await HTTPAgent()
          .post('${Endpoint.url}/blockchain/$blockchainId/gas-limit', payload);
      Log.debug(payload);
      if (response.success) {
        Map<String, dynamic> data = response.data;
        this._gasLimit = int.parse(data['gasLimit']);
        Log.warning('this._gasLimit: $this._gasLimit');
      } else {
        // throw Exception(response.message);
        Log.debug(response.message);
        this._gasLimit = 9000;
      }
      return Decimal.fromInt(this._gasLimit!);
    }
  }

  Future<Map<TransactionPriority, Decimal>> getFeePerUnit(
      String blockchainId) async {
    if (_fee == null ||
        DateTime.now().millisecondsSinceEpoch - _feeTimestamp! >
            this.AVERAGE_FETCH_FEE_TIME) {
      APIResponse response =
          await HTTPAgent().get('${Endpoint.url}/blockchain/$blockchainId/fee');
      if (response.success) {
        Map<String, dynamic> data = response.data; // FEE will return String
        _fee = {
          TransactionPriority.slow: Decimal.parse(data['slow']),
          TransactionPriority.standard: Decimal.parse(data['standard']),
          TransactionPriority.fast: Decimal.parse(data['fast']),
        };
        _feeTimestamp = DateTime.now().millisecondsSinceEpoch;
        return _fee!;
      } else {
        throw Exception(response.message);
      }
    } else {
      return _fee!;
    }
  }

  @override
  Future<Map> getTransactionFee({
    required String blockchainId,
    required int decimals,
    String? to,
    String? amount,
    String? message,
    TransactionPriority? priority,
  }) async {
    Map<TransactionPriority, Decimal> feePerUnit =
        await this.getFeePerUnit(blockchainId);
    Decimal feeUint = await this.estimateGasLimit(
        blockchainId,
        await this.getReceivingAddress(),
        to ?? "",
        amount ?? "0",
        message ?? "0x");
    return {
      "feePerUnit": {...feePerUnit},
      "unit": feeUint
    };
  }

  @override
  Future<String> getReceivingAddress() async {
    if (this._address != null) {
      return this._address!;
    } else {
      APIResponse response = await HTTPAgent().get(
          '${Endpoint.url}/wallet/account/address/${this.shareAccountId}/receive');
      if (response.success) {
        String address = response.data['address'];
        this._address = address;

        Log.debug('_address: ${this._address}');
        return address;
      } else {
        throw Exception(response.message);
      }
    }
  }

  @override
  Future<Map> getChangingAddress() async {
    return {"address": getReceivingAddress()};
  }

  @override
  Future<int> getNonce(String blockchainId, String address) async {
    APIResponse response = await HTTPAgent()
        .get('${Endpoint.url}/blockchain/$blockchainId/address/$address/nonce');
    if (response.success) {
      Map data = response.data;
      int nonce = int.parse(data['nonce']);
      _nonce = nonce;
      return nonce;
    } else {
      //TODO
      return ++_nonce;
    }
  }

  @override
  Future<List> publishTransaction(
      String blockchainId, Transaction transaction) async {
    //TODO TEST
    Log.debug("publishTransaction");
    Log.debug(hex.encode(transaction.serializeTransaction));

    APIResponse response = await HTTPAgent().post(
        '${Endpoint.url}/blockchain/$blockchainId/push-tx',
        {"hex": '0x' + hex.encode(transaction.serializeTransaction)});
    bool success = response.success;
    // transaction.id = response.data['txid'];
    transaction.txId = response.data['txid'];
    transaction.timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    transaction.confirmations = 0;
    return [success, transaction];
  }

  @override
  Future synchro({bool? force}) async {
    await this.service.synchro(force: force);
  }

  @override
  Future updateTransaction(String accountid, Map payload) {
    return this.service.updateTransaction(accountid, payload);
  }

  @override
  Future updateAccount(String accountid, Map payload) {
    return this.service.updateAccount(accountid, payload);
  }
}
