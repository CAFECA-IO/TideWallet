import 'dart:async';
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:convert/convert.dart';

import 'account_service.dart';
import 'account_service_decorator.dart';
import '../models/transaction.model.dart';
import '../models/bitcoin_transaction.model.dart';
import '../models/utxo.model.dart';
import '../helpers/http_agent.dart';
import '../constants/account_config.dart';
import '../database/db_operator.dart';
import '../database/entity/utxo.dart' as UtxoEntity;

class BitcoinService extends AccountServiceDecorator {
  BitcoinService(AccountService service) : super(service) {
    this.base = ACCOUNT.BTC;
    HTTPAgent().setToken('token'); //TODO TEST
  }
  static const String _baseUrl = 'https://service.tidewallet.io';

  Timer _timer;
  int _numberOfUsedExternalKey;
  int _numberOfUsedInternalKey;
  int _lastSyncTimestamp;

  // @override
  // Decimal calculateFastFee() {
  //   // TODO: implement calculateFastFee
  //   throw UnimplementedError();
  // }

  // @override
  // Decimal calculateSlowFee() {
  //   // TODO: implement calculateSlowFee
  //   throw UnimplementedError();
  // }

  // @override
  // Decimal calculateStandardFee() {
  //   // TODO: implement calculateStandardFee
  //   throw UnimplementedError();
  // }

  @override
  getTransactions() {
    // TODO: implement getTransactions
    throw UnimplementedError();
  }

  @override
  void init() {
    // TODO: implement init
  }

  // @override
  // prepareTransaction() {
  //   // TODO: implement prepareTransaction
  //   throw UnimplementedError();
  // }

  @override
  void start() {
    // TODO: implement start
  }

  @override
  void stop() {
    // TODO: implement stop
  }

  // @override
  // Decimal toCoinUnit(Decimal satoshi) {
  //   return satoshi / _btcInSatoshi;
  // }

  // @override
  // Decimal toSmallUnit(Decimal btc) {
  //   return btc * _btcInSatoshi;
  // }

  @override
  Future<Decimal> estimateGasLimit(
      String from, String to, String amount, String data) {
    // TODO: implement estimateGasLimit
    throw UnimplementedError();
  }

  @override
  Future<Map<TransactionPriority, Decimal>> getTransactionFee() async {
    // TODO getSyncFeeAutomatically
    Response response =
        await HTTPAgent().get('$_baseUrl/api/v1/blockchain/80000001/fee');
    Map<String, dynamic> data =
        response.data['payload']; // FEE will return String

    Map<TransactionPriority, Decimal> transactionFee = {
      TransactionPriority.slow: Decimal.parse(data['slow']),
      TransactionPriority.standard: Decimal.parse(data['standard']),
      TransactionPriority.fast: Decimal.parse(data['fast']),
    };
    return transactionFee;
  }

  @override
  Future<String> getChangingAddress(String currencyId) async {
    Response response = await HTTPAgent()
        .get('$_baseUrl/api/v1/wallet/account/address/$currencyId/change');
    Map data = response.data['payload'];
    String _address = data['address'];
    _numberOfUsedInternalKey = data['change_index'];
    return _address;
  }

  @override
  Future<String> getReceivingAddress(String currencyId) async {
    Response response = await HTTPAgent()
        .get('$_baseUrl/api/v1/wallet/account/address/$currencyId/receive');
    Map data = response.data['payload'];
    String address = data['address'];
    _numberOfUsedExternalKey = data['key_index'];
    return address;
  }

  @override
  Future<List<UnspentTxOut>> getUnspentTxOut(String currencyId) async {
    // TODO 應該要放在sync裡面
    // Response response = await HTTPAgent()
    //     .get('$_baseUrl/api/v1/wallet/account/txs/uxto/$currencyId');
    // List<dynamic> datas = response.data['payload'];
    // List<UtxoEntity.Utxo> utxos = datas
    //     .map((data) => UtxoEntity.Utxo(
    //           data['id'],
    //           currencyId,
    //           data['txid'],
    //           data['vout'],
    //           data['type'],
    //           data['amount'],
    //           data['chain_index'],
    //           data['key_index'],
    //           data['script'],
    //           data['timestamp'],
    //           false,
    //           BitcoinTransaction.DEFAULT_SEQUENCE,
    //         ))
    //     .toList();
    // DBOperator().utxoDao.insertUtxos(utxos);
    List<UtxoEntity.Utxo> utxos =
        await DBOperator().utxoDao.findAllUtxosByCurrencyId(currencyId);
    return utxos.map((utxo) => UnspentTxOut.fromUtxoEntity(utxo)).toList();
  }

  @override
  Future<void> publishTransaction(
      String blockchainId, String currencyId, Transaction transaction) async {
    await HTTPAgent().post(
        '$_baseUrl/api/v1/blockchain/$blockchainId/push-tx/$currencyId',
        {"hex": transaction.serializedData});
    return;
  }

  @override
  Future<int> getNonce() {
    // TODO: implement getNonce
    throw UnimplementedError();
  }
}
