import 'dart:async';
import 'package:convert/convert.dart';
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';

import 'account_service_decorator.dart';

import '../models/utxo.model.dart';
import '../models/account.model.dart';
import '../models/transaction.model.dart';
import '../constants/account_config.dart';
import '../services/account_service.dart';
import '../mock/endpoint.dart';
import '../cores/account.dart';
import '../helpers/http_agent.dart';

class EthereumService extends AccountServiceDecorator {
  EthereumService(AccountService service) : super(service) {
    this.base = ACCOUNT.ETH;
  }
  static const String _baseUrl = 'https://service.tidewallet.io';

  Timer _timer;
  String _address;
  String _contract; // ?
  String _tokenAddress; // ?

  getTransactions() {}
  getBalance() {}
  getTokenTransactions() {}
  getTokenBalance() {}
  getTokenInfo() {}

  @override
  Future<List<UnspentTxOut>> getUnspentTxOut(String currencyId) async {
    // TODO: implement getUnspentTxOut
    throw UnimplementedError();
  }

  @override
  void init() {
    // TODO: implement init
  }

  @override
  void start() {
    this._sync();
  }

  @override
  void stop() {
    _timer?.cancel();
  }

  _sync() {
    _timer =
        Timer.periodic(Duration(milliseconds: this.syncInterval), (_) async {
      await this._getTokens();
      Currency curr = await this._getETH();

      AccountMessage msg =
          AccountMessage(evt: ACCOUNT_EVT.OnUpdateAccount, value: curr);

      AccountMessage currMsg = AccountMessage(
          evt: ACCOUNT_EVT.OnUpdateCurrency,
          value: AccountCore().currencies[this.base]);

      AccountCore().messenger.add(msg);
      AccountCore().messenger.add(currMsg);

      List<Transaction> transactions = await this._getTransactions();

      AccountMessage txMsg = AccountMessage(
          evt: ACCOUNT_EVT.OnUpdateTransactions,
          value: {"currency": curr, "transactions": transactions});
      AccountCore().messenger.add(txMsg);
    });
  }

  _getTransactions() async {
    // TODO get transactions from api
    List<Transaction> result = await getETHTransactions();
    return result;
  }

  _getTokens() async {
    List<Map> result = await getETHTokens();
    List<Currency> tokenList = result.map((e) => Currency.fromMap(e)).toList();

    AccountCore().currencies[this.base] =
        AccountCore().currencies[this.base].sublist(0, 1) + tokenList;
  }

  Future<Currency> _getETH() async {
    Map res = await getETH();
    Currency curr = Currency.fromMap({...res, "accountType": this.base});
    AccountCore().currencies[curr.accountType][0] = curr;
    return curr;
  }

  static Future<Token> getTokeninfo(String _address) async {
    Future.delayed(Duration(milliseconds: 1000));
    Map result = await getETHTokeninfo(_address);
    if (result != null && result['success']) {
      Token _token = Token(
          symbol: result['symbol'],
          name: result['name'],
          decimal: result['decimal'],
          imgUrl: result['imgPath'],
          description: result['description'],
          contract: result['contract'],
          totalSupply: result['totalSupply']);
      return _token;
    } else {
      return null;
    }
  }

  Future<bool> addToken(Token tk) async {
    await Future.delayed(Duration(milliseconds: 500));

    return true;
  }

  @override
  Future<Decimal> estimateGasLimit(String blockchainId, String from, String to,
      String amount, String message) async {
    Response response = await HTTPAgent().post(
        '$_baseUrl/api/v1/blockchain/$blockchainId/gas-limit', {
      "fromAddress": from,
      "toAddress": to,
      "value": amount,
      "data": message
    }); // TODO API FormatError
    Map<String, dynamic> data = response.data['payload'];
    int gasLimit = data['gasLimit'];
    return Decimal.fromInt(gasLimit);
  }

  @override
  Future<Map<TransactionPriority, Decimal>> getTransactionFee(
      String blockchainId) async {
    // TODO getSyncFeeAutomatically
    Response response =
        await HTTPAgent().get('$_baseUrl/api/v1/blockchain/$blockchainId/fee');
    Map<String, dynamic> data = response.data['payload'];
    Map<TransactionPriority, Decimal> transactionFee = {
      TransactionPriority.slow: Decimal.parse(data['slow'].toString()),
      TransactionPriority.standard: Decimal.parse(data['standard'].toString()),
      TransactionPriority.fast: Decimal.parse(data['fast'].toString()),
    };
    return transactionFee;
  }

  @override
  Future<List> getReceivingAddress(String currencyId) async {
    if (this._address == null) {
      Response response = await HTTPAgent()
          .get('$_baseUrl/api/v1/wallet/account/address/$currencyId/receive');
      Map data = response.data['payload'];
      String address = data['address'];
      this._address = address;
    }
    return [this._address];
  }

  @override
  Future<List> getChangingAddress(String currencyId) async {
    return await getReceivingAddress(currencyId);
  }

  @override
  Future<int> getNonce(String blockchainId) async {
    Response response = await HTTPAgent()
        .get('$_baseUrl/api/v1/blockchain/$blockchainId/nonce');
    Map data = response.data['payload'];
    int nonce = int.parse(data['nonce']);
    return nonce;
  }

  @override
  Future<void> publishTransaction(
      String blockchainId, String currencyId, Transaction transaction) async {
    await HTTPAgent().post(
        '$_baseUrl/api/v1/blockchain/$blockchainId/push-tx/$currencyId',
        {"hex": hex.encode(transaction.serializeTransaction)});
    return;
  }
}
