import 'dart:async';
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
  late String _address;
  late Map<TransactionPriority, Decimal> _fee;
  late int _gasLimit;
  late int _feeTimestamp; // fetch transactionFee timestamp;
  // int _gasLimitTimestamp; // fetch estimatedGas timestamp;
  int _nonce = 0;

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
            this.service.shareAccountId!,
            AccountCore().accounts[this.service.shareAccountId]![0].userId);

        await DBOperator().accountDao.insertAccount(v);

        List<JoinAccount> jcs = await DBOperator()
            .accountDao
            .findJoinedAccountsByShareAccountId(this.service.shareAccountId!);

        List<Account> cs = jcs
            .map((c) => Account.fromJoinAccount(c, jcs[0], this.base!))
            .toList();

        AccountMessage msg =
            AccountMessage(evt: ACCOUNT_EVT.OnUpdateAccount, value: cs[0]);
        AccountCore().accounts[this.service.shareAccountId!] = cs;

        AccountMessage currMsg = AccountMessage(
            evt: ACCOUNT_EVT.OnUpdateAccount,
            value: AccountCore().accounts[this.service.shareAccountId]);

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

  Future<Decimal> estimateGasLimit(String blockchainId, String from, String to,
      String amount, String message) async {
    if (message == '0x' && _gasLimit != null)
      return Decimal.fromInt(_gasLimit);
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
        _gasLimit = int.parse(data['gasLimit']);
        Log.warning('_gasLimit: $_gasLimit');
      } else {
        // TODO
        // _gasLimit = 21000;
        throw Exception(response.message);
      }
      return Decimal.fromInt(_gasLimit);
    }
  }

  @override
  Future<Map<TransactionPriority, Decimal>> getTransactionFee(
      String blockchainId) async {
    // TODO getSyncFeeAutomatically
    if (_fee == null ||
        DateTime.now().millisecondsSinceEpoch - _feeTimestamp >
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
      } else {
        // TODO fee = null 前面會出錯
      }
    }
    return _fee;
  }

  @override
  Future<List> getReceivingAddress(String currencyId) async {
    if (this._address == null) {
      APIResponse response = await HTTPAgent()
          .get('${Endpoint.url}/wallet/account/address/$currencyId/receive');
      if (response.success) {
        Map data = response.data;
        String address = data['address'];
        this._address = address;

        Log.debug('_address: ${this._address}');
        return [this._address, null];
      } else {
        //TODO
        return ['error', 0];
      }
    }
    Log.debug('_address: ${this._address}');
    return [this._address, null];
  }

  @override
  Future<List> getChangingAddress(String currencyId) async {
    return await getReceivingAddress(currencyId);
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
