import 'dart:async';
import 'package:convert/convert.dart';
import 'package:decimal/decimal.dart';

import 'account_service_decorator.dart';

import '../models/utxo.model.dart';
import '../models/account.model.dart';
import '../models/transaction.model.dart';
import '../models/api_response.mode.dart';
import '../constants/account_config.dart';
import '../services/account_service.dart';
import '../mock/endpoint.dart';
import '../helpers/logger.dart';
import '../cores/account.dart';
import '../helpers/http_agent.dart';

class EthereumService extends AccountServiceDecorator {
  EthereumService(AccountService service) : super(service) {
    this.base = ACCOUNT.ETH;
    this.syncInterval = 5 * 60 * 1000;
  }
  static const String _baseUrl = 'https://service.tidewallet.io';
  String _address;
  String _contract; // ?
  String _tokenAddress; // ?

  @override
  Future<List<UnspentTxOut>> getUnspentTxOut(String currencyId) async {
    // TODO: implement getUnspentTxOut
    throw UnimplementedError();
  }

  @override
  void init(String id, ACCOUNT base, { int interval }) {
    Log.debug('ETH Service Init');
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
    APIResponse response = await HTTPAgent().post(
        '$_baseUrl/api/v1/blockchain/$blockchainId/gas-limit', {
      "fromAddress": from,
      "toAddress": to,
      "value": amount,
      "data": message
    }); // TODO API FormatError
    Map<String, dynamic> data = response.data;
    int gasLimit = data['gasLimit'];
    return Decimal.fromInt(gasLimit);
  }

  @override
  Future<Map<TransactionPriority, Decimal>> getTransactionFee(
      String blockchainId) async {
    // TODO getSyncFeeAutomatically
    APIResponse response =
        await HTTPAgent().get('$_baseUrl/api/v1/blockchain/$blockchainId/fee');
    Map<String, dynamic> data = response.data;
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
      APIResponse response = await HTTPAgent()
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
    APIResponse response = await HTTPAgent()
        .get('$_baseUrl/api/v1/blockchain/$blockchainId/nonce');
    Map data = response.data;
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

  @override
  getTransactions() {
    // TODO: implement getTransactions
    throw UnimplementedError();
  }
}
