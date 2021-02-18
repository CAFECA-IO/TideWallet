import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:tidewallet3/helpers/logger.dart';
import 'package:decimal/decimal.dart';
import 'package:convert/convert.dart';
import 'package:tidewallet3/models/api_response.mode.dart';

import 'account_service.dart';
import 'account_service_decorator.dart';
import '../models/transaction.model.dart';
import '../models/bitcoin_transaction.model.dart';
import '../models/utxo.model.dart';
import '../helpers/http_agent.dart';
import '../constants/account_config.dart';
import '../database/db_operator.dart';
import '../database/entity/utxo.dart';

class BitcoinService extends AccountServiceDecorator {
  Timer _utxoTimer;
  BitcoinService(AccountService service) : super(service) {
    this.base = ACCOUNT.BTC;
    this.syncInterval = 5 * 60 * 1000;
  }
  static const String _baseUrl = 'https://service.tidewallet.io';

  Timer _timer;
  int _numberOfUsedExternalKey;
  int _numberOfUsedInternalKey;
  int _lastSyncTimestamp;

  @override
  getTransactions() {
    // TODO: implement getTransactions
    throw UnimplementedError();
  }

  @override
  void init(String id, ACCOUNT base, {int interval}) {
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

    await this._syncUTXO();

    this._utxoTimer = Timer.periodic(Duration(milliseconds: this.syncInterval), (_) {
      this._syncUTXO();
    });
  }

  @override
  void stop() {
    this.service.stop();

    _utxoTimer?.cancel();
  }

  @override
  Future<int> getNonce(String blockchainId) {
    // TODO: implement getNonce
    throw UnimplementedError();
  }

  @override
  Future<Decimal> estimateGasLimit(
      String blockchainId, String from, String to, String amount, String data) {
    // TODO: implement estimateGasLimit
    throw UnimplementedError();
  }

  @override
  Future<Map<TransactionPriority, Decimal>> getTransactionFee(
      String blockchainId) async {
    // TODO getSyncFeeAutomatically
    APIResponse response =
        await HTTPAgent().get('$_baseUrl/api/v1/blockchain/$blockchainId/fee');
    Map<String, dynamic> data =
        response.data; // FEE will return String

    Map<TransactionPriority, Decimal> transactionFee = {
      TransactionPriority.slow: Decimal.parse(data['slow']),
      TransactionPriority.standard: Decimal.parse(data['standard']),
      TransactionPriority.fast: Decimal.parse(data['fast']),
    };
    return transactionFee;
  }

  @override
  Future<List> getChangingAddress(String currencyId) async {
    APIResponse response = await HTTPAgent()
        .get('$_baseUrl/api/v1/wallet/account/address/$currencyId/change');
    Map data = response.data;
    String _address = data['address'];
    _numberOfUsedInternalKey = data['change_index'];
    return [_address, _numberOfUsedInternalKey];
  }

  @override
  Future<List> getReceivingAddress(String currencyId) async {
    APIResponse response = await HTTPAgent()
        .get('$_baseUrl/api/v1/wallet/account/address/$currencyId/receive');
    Map data = response.data;
    String address = data['address'];
    _numberOfUsedExternalKey = data['key_index'];
    return [address, _numberOfUsedExternalKey];
  }

  @override
  Future<List<UnspentTxOut>> getUnspentTxOut(String currencyId) async {
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
    List<UtxoEntity> utxos =
        await DBOperator().utxoDao.findAllUtxosByCurrencyId(currencyId);
    return utxos.map((utxo) => UnspentTxOut.fromUtxoEntity(utxo)).toList();
  }

  @override
  Future<void> publishTransaction(
      String blockchainId, String currencyId, Transaction transaction) async {
    await HTTPAgent().post(
        '$_baseUrl/api/v1/blockchain/$blockchainId/push-tx/$currencyId',
        {"hex": hex.encode(transaction.serializeTransaction)});
    // updateUsedUtxo
    BitcoinTransaction _transaction = transaction;
    _transaction.inputs.forEach((Input input) async {
      UnspentTxOut _utxo = input.utxo;
      _utxo.locked = true;
      await DBOperator()
          .utxoDao
          .updateUtxo(UtxoEntity.fromUnspentUtxo(_utxo));
    });
    // insertChangeUtxo
    if (transaction.changeUtxo != null) {
      await DBOperator()
          .utxoDao
          .insertUtxo(UtxoEntity.fromUnspentUtxo(transaction.changeUtxo));
    }
    // informBackend
    // updateCurrencyAmount
    return;
  }

  Future _syncUTXO() async {
    int now = DateTime.now().millisecondsSinceEpoch;

    if (now - this.service.lastSyncTimestamp > this.syncInterval) {
      Log.info('_syncUTXO');
      this.getUnspentTxOut(this.service.accountId);
    }
  }
}
