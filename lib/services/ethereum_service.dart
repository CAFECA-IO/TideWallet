import 'dart:async';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:decimal/decimal.dart';

import 'account_service_decorator.dart';

import '../models/utxo.model.dart';
import '../models/account.model.dart';
import '../models/transaction.model.dart';
import '../models/api_response.mode.dart';
import '../constants/account_config.dart';
import '../constants/endpoint.dart';
import '../services/account_service.dart';
import '../helpers/cryptor.dart';
import '../helpers/logger.dart';
import '../helpers/http_agent.dart';
import '../cores/account.dart';
import '../cores/paper_wallet.dart';
import '../database/db_operator.dart';
import '../database/entity/account_currency.dart';
import '../database/entity/currency.dart';

class EthereumService extends AccountServiceDecorator {
  EthereumService(AccountService service) : super(service) {
    this.base = ACCOUNT.ETH;
    this.syncInterval = 7500;
    // this.syncInterval = 1 * 60 * 1000;
    // this.path = "m/44'/60'/0'";
  }
  String _address;
  String _contract; // ?
  String _tokenAddress; // ?
  Map<TransactionPriority, Decimal> _fee;
  int _gasLimit;
  int _feeTimestamp; // fetch transactionFee timestamp;
  // int _gasLimitTimestamp; // fetch estimatedGas timestamp;
  int _nonce = 0;

  @override
  Future<List<UnspentTxOut>> getUnspentTxOut(String currencyId) async {
    // TODO: implement getUnspentTxOut
    throw UnimplementedError();
  }

  @override
  void init(String id, ACCOUNT base, {int interval}) {
    Log.eth('ETH Service Init');
    this.service.init(id, this.base, interval: this.syncInterval);
  }

  @override
  prepareTransaction() {
    // TODO: implement prepareTransaction
    throw UnimplementedError();
  }

  @override
  Future start() async {
    await this.service.start();
  }

  @override
  void stop() {
    this.service.stop();
  }

  @override
  Decimal toCoinUnit() {
    // TODO: implement toCoinUnit
    throw UnimplementedError();
  }

  @override
  Decimal toSmallUnit() {
    // TODO: implement toSmallUnit
    throw UnimplementedError();
  }

  static Future<Token> getTokeninfo(String blockchainId, String address) async {
    Future.delayed(Duration(milliseconds: 1000));
    APIResponse res = await HTTPAgent()
        .get(Endpoint.SUSANOO + '/blockchain/$blockchainId/contract/$address');

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
      return null;
    }
  }

  Future<bool> addToken(String blockchainId, Token tk) async {
    APIResponse res = await HTTPAgent().post(
        Endpoint.SUSANOO +
            '/wallet/blockchain/$blockchainId/contract/${tk.contract}',
        {});
    if (res.success == false) return false;
    Log.debug('Token res.data: ${res.data}');

    try {
      String id = res.data['token_id'];
      APIResponse updateRes = await HTTPAgent()
          .get(Endpoint.SUSANOO + '/wallet/account/${this.service.accountId}');

      if (updateRes.success) {
        final acc = updateRes.data;
        List tks = [acc] + acc['tokens'];
        final index = tks.indexWhere((token) => token['token_id'] == id);
        var data = {
          ...tks[index],
          'icon': tk.imgUrl ?? acc['icon'],
          'currency_id': id
        };
        Log.debug("Token data: $data");

        await DBOperator().currencyDao.insertCurrency(
              CurrencyEntity.fromJson(
                {
                  ...tks[index],
                  'icon': tk.imgUrl ?? acc['icon'],
                  'currency_id': id
                },
              ),
            );
        Log.info(id);

        int now = DateTime.now().millisecondsSinceEpoch;
        final v = AccountCurrencyEntity.fromJson(
            tks[index], this.service.accountId, now);

        await DBOperator().accountCurrencyDao.insertAccount(v);

        List<JoinCurrency> jcs = await DBOperator()
            .accountCurrencyDao
            .findJoinedByAccountId(this.service.accountId);

        List<Currency> cs = jcs
            .map((c) => Currency.fromJoinCurrency(c, jcs[0], this.base))
            .toList();

        AccountMessage msg =
            AccountMessage(evt: ACCOUNT_EVT.OnUpdateAccount, value: cs[0]);
        AccountCore().currencies[this.service.accountId] = cs;

        AccountMessage currMsg = AccountMessage(
            evt: ACCOUNT_EVT.OnUpdateCurrency,
            value: AccountCore().currencies[this.service.accountId]);

        AccountCore().messenger.add(msg);
        AccountCore().messenger.add(currMsg);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      Log.error(e);

      return false;
    }
  }

  @override
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
      APIResponse response = await HTTPAgent().post(
          '${Endpoint.SUSANOO}/blockchain/$blockchainId/gas-limit', payload);
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
      APIResponse response = await HTTPAgent()
          .get('${Endpoint.SUSANOO}/blockchain/$blockchainId/fee');
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
      APIResponse response = await HTTPAgent().get(
          '${Endpoint.SUSANOO}/wallet/account/address/$currencyId/receive');
      if (response.success) {
        Map data = response.data;
        String address = data['address'];
        this._address = address;

// TEST
        // // IMPORTANT: seed cannot reach
        String seed =
            '4f796f9ed67db3885f1ec75407dd257391f05b91ce8454dbc8636930c5124912';
        // '74a0b10d85dea97d53ff42a89f34a8447bbd041dcb573333358a03d5d1cfff0e';
        // '59f45d6afb9bc00380fed2fcfdd5b36819acab89054980ad6e5ff90ba19c5347'; // 上一個有eth的 seed
        Uint8List publicKey = await PaperWallet.getPubKey(
            hex.decode(seed), 0, 0,
            compressed: false);
        String caculatedAddress = '0x' +
            hex
                .encode(Cryptor.keccak256round(
                    publicKey.length % 2 != 0
                        ? publicKey.sublist(1)
                        : publicKey,
                    round: 1))
                .substring(24, 64);
        Log.debug('caculatedAddress: $caculatedAddress');
// TEST(end)
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
    APIResponse response = await HTTPAgent().get(
        '${Endpoint.SUSANOO}/blockchain/$blockchainId/address/$address/nonce');
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
        '${Endpoint.SUSANOO}/blockchain/$blockchainId/push-tx',
        {"hex": '0x' + hex.encode(transaction.serializeTransaction)});
    bool success = response.success;
    // transaction.id = response.data['txid'];
    transaction.txId = response.data['txid'];
    transaction.timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    transaction.confirmations = 0;
    return [success, transaction];
  }

  @override
  getTransactions() {
    // TODO: implement getTransactions
    throw UnimplementedError();
  }
}
