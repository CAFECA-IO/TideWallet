import 'dart:async';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';

import 'account_service_decorator.dart';

import '../models/utxo.model.dart';
import '../models/account.model.dart';
import '../models/transaction.model.dart';
import '../models/api_response.mode.dart';
import '../constants/account_config.dart';
import '../constants/endpoint.dart';
import '../services/account_service.dart';
import '../mock/endpoint.dart';
import '../helpers/logger.dart';
import '../helpers/http_agent.dart';

import '../cores/paper_wallet.dart';
import '../helpers/cryptor.dart';
import '../helpers/logger.dart';

class EthereumService extends AccountServiceDecorator {
  EthereumService(AccountService service) : super(service) {
    this.base = ACCOUNT.ETH;
    this.syncInterval = 5 * 60 * 1000;
  }
  String _address;
  String _contract; // ?
  String _tokenAddress; // ?

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
    Map<String, dynamic> payload = {
      "fromAddress": from,
      "toAddress": to,
      "value": amount,
      "data": message
    };
    APIResponse response = await HTTPAgent().post(
        '${Endpoint.SUSANOO}/blockchain/$blockchainId/gas-limit', payload);
    Log.debug(payload);
    Map<String, dynamic> data = response.data;
    int gasLimit = int.parse(data['gasLimit']);
    return Decimal.fromInt(gasLimit);
  }

  @override
  Future<Map<TransactionPriority, Decimal>> getTransactionFee(
      String blockchainId) async {
    // TODO getSyncFeeAutomatically
    APIResponse response = await HTTPAgent()
        .get('${Endpoint.SUSANOO}/blockchain/$blockchainId/fee');
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
    // if (this._address == null) {
    APIResponse response = await HTTPAgent()
        .get('${Endpoint.SUSANOO}/wallet/account/address/$currencyId/receive');
    Map data = response.data;
    String address = data['address'];
    this._address = address;
    Log.debug(this._address);

    // TEST
    String seed =
        'e44914bee7e336f54a746421e2d7f9c99daccfac274ad03605b73c39601274ab';
    Uint8List publicKey =
        await PaperWallet.getPubKey(hex.decode(seed), 0, 0, compressed: false);
    // Uint8List privKey = await PaperWallet.getPrivKey(hex.decode(seed), 0, 0);
    // Log.debug('privKey: ${hex.encode(privKey)}');
    String calculatedaddress = '0x' +
        hex
            .encode(Cryptor.keccak256round(
                publicKey.length % 2 != 0 ? publicKey.sublist(1) : publicKey,
                round: 1))
            .substring(24, 64);

    Log.debug(calculatedaddress);
    // TEST(end)
    // }

    return [this._address];
  }

  @override
  Future<List> getChangingAddress(String currencyId) async {
    return await getReceivingAddress(currencyId);
  }

  @override
  Future<int> getNonce(String blockchainId, String address) async {
    APIResponse response = await HTTPAgent().get(
        '${Endpoint.SUSANOO}/blockchain/$blockchainId/address/$address/nonce');
    Map data = response.data;
    int nonce = int.parse(data['nonce']);
    return nonce;
  }

  @override
  Future<void> publishTransaction(
      String blockchainId, Transaction transaction) async {
    //TODO TEST
    Log.debug("publishTransaction");

    Log.debug(transaction.serializeTransaction);
    Log.debug(hex.encode(transaction.serializeTransaction));

    await HTTPAgent().post(
        '${Endpoint.SUSANOO}/blockchain/$blockchainId/push-tx',
        {"hex": '0x' + hex.encode(transaction.serializeTransaction)});
    return;
  }

  @override
  getTransactions() {
    // TODO: implement getTransactions
    throw UnimplementedError();
  }
}
