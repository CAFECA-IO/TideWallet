import 'dart:async';
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:convert/convert.dart';

import 'account_service.dart';
import 'account_service_decorator.dart';

import '../models/api_response.mode.dart';
import '../models/transaction.model.dart';
import '../models/bitcoin_transaction.model.dart';
import '../models/utxo.model.dart';
import '../helpers/logger.dart';
import '../helpers/http_agent.dart';
import '../constants/endpoint.dart';
import '../constants/account_config.dart';
import '../database/db_operator.dart';
import '../database/entity/utxo.dart';

class BitcoinService extends AccountServiceDecorator {
  BitcoinService(AccountService service) : super(service) {
    this.base = ACCOUNT.BTC;
    this.syncInterval = 10 * 60 * 1000;
    // this.path = "m/44'/0'/0'";
  }
  int? _numberOfUsedExternalKey;
  int? _numberOfUsedInternalKey;
  int? _lastSyncTimestamp;
  Map<TransactionPriority, Decimal>? _fee;
  int? _feeTimestamp; // fetch transactionFee timestamp;

  @override
  void init(String id, ACCOUNT base, {int? interval}) {
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

  Decimal calculateTransactionVSize({
    required List<UnspentTxOut> unspentTxOuts,
    required Decimal feePerByte,
    required Decimal amount,
    Uint8List? message,
    SegwitType segwitType = SegwitType.nativeSegWit, // ++ TODO 2021/8/18
  }) {
    Decimal unspentAmount = Decimal.zero;
    int headerWeight;
    int inputWeight;
    int outputWeight;
    if (segwitType == SegwitType.nativeSegWit) {
      headerWeight = 3 * 10 + 12;
      inputWeight = 3 * 41 + 151;
      outputWeight = 3 * 31 + 31;
    } else if (segwitType == SegwitType.segWit) {
      headerWeight = 3 * 10 + 12;
      inputWeight = 3 * 76 + 210;
      outputWeight = 3 * 32 + 32;
    } else {
      headerWeight = 3 * 10 + 10;
      inputWeight = 3 * 148 + 148;
      outputWeight = 3 * 34 + 34;
    }
    int numberOfTxIn = 0;
    int numberOfTxOut = message != null ? 2 : 1;
    int vsize =
        0; // 3 * base_size(excluding witnesses) + total_size(including witnesses)
    for (UnspentTxOut utxo in unspentTxOuts) {
      ++numberOfTxIn;
      unspentAmount += utxo.amount;
      vsize = ((headerWeight +
              (inputWeight * numberOfTxIn) +
              (outputWeight * numberOfTxOut) +
              3) ~/
          4);
      Decimal fee = Decimal.fromInt(vsize) * feePerByte;
      if (unspentAmount == (amount + fee)) break;

      if (unspentAmount > (amount + fee)) {
        numberOfTxOut = 3;
        vsize = ((headerWeight +
                (inputWeight * numberOfTxIn) +
                (outputWeight * numberOfTxOut) +
                3) ~/
            4);
        Decimal fee = Decimal.fromInt(vsize) * feePerByte;
        if (unspentAmount >= (amount + fee)) break;
      }
    }
    Decimal fee = Decimal.fromInt(vsize) * feePerByte;
    return fee;
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
    List<UnspentTxOut> utxos = await this.getUnspentTxOut(shareAccountId);
    Decimal feeUint = this.calculateTransactionVSize(
        unspentTxOuts: utxos,
        feePerByte: feePerUnit[priority]!,
        amount: Decimal.parse(amount ?? '0'));
    return {
      "feePerUnit": {...feePerUnit},
      "unit": feeUint
    };
  }

  Future<Map> getChangingAddress() async {
    APIResponse response = await HTTPAgent().get(
        '${Endpoint.url}/wallet/account/address/${this.shareAccountId}/change');
    if (response.success) {
      Map data = response.data;
      String _address = data['address'];
      _numberOfUsedInternalKey = data['key_index'];
      return {"address": _address, "keyIndex": _numberOfUsedInternalKey};
    } else {
      throw Exception(response.message);
    }
  }

  @override
  Future<String> getReceivingAddress() async {
    APIResponse response = await HTTPAgent().get(
        '${Endpoint.url}/wallet/account/address/${this.shareAccountId}/receive');
    if (response.success) {
      Map data = response.data;
      String address = data['address'];
      _numberOfUsedExternalKey = data['key_index'];
      return address;
    } else {
      throw Exception('Some went wrong');
    }
  }

  Future<List<UnspentTxOut>> getUnspentTxOut(String currencyId) async {
    List<JoinUtxo> utxos =
        await DBOperator().utxoDao.findAllJoinedUtxosById(currencyId);
    return utxos.map((utxo) => UnspentTxOut.fromUtxoEntity(utxo)).toList();

    // TODO TEST
    // List<JoinUtxo> _utxos = [];
    // JoinUtxo _utxo = JoinUtxo.fromUnspentUtxo(UnspentTxOut(
    //     id: 'e4962c7cc3875d5bde9b1dd92fcd2238a09ea5c42bc81f93152909974d8164e7',
    //     accountcurrencyId: "e6e93f49-ef32-42c4-a7a5-806b6d53778e",
    //     txId:
    //         'e4962c7cc3875d5bde9b1dd92fcd2238a09ea5c42bc81f93152909974d8164e7',
    //     vout: 1,
    //     type: BitcoinTransactionType.WITNESS_V0_KEYHASH,
    //     data: Uint8List(0),
    //     amount: Decimal.parse('0.01156275'),
    //     address: 'tb1q8x0nw29tvc7zkgc24j2h28mt8mutewcq8zj59h',
    //     chainIndex: 0,
    //     keyIndex: 0,
    //     timestamp: DateTime.now().millisecondsSinceEpoch ~/1000,
    //     locked: true,
    //     decimals: 8));
    // _utxos.add(_utxo);
    // JoinUtxo _changeUtxo = JoinUtxo.fromUnspentUtxo(UnspentTxOut(
    //     id: '0e5d8076addeac19a9fc0c003f1a4c5330892dfb9e7fe362eb50b7c75b470349',
    //     accountcurrencyId: "e6e93f49-ef32-42c4-a7a5-806b6d53778e",
    //     txId:
    //         '0e5d8076addeac19a9fc0c003f1a4c5330892dfb9e7fe362eb50b7c75b470349',
    //     vout: 1,
    //     type: BitcoinTransactionType.WITNESS_V0_KEYHASH,
    //     data: Uint8List(0),
    //     amount: Decimal.parse('0.01119572'),
    //     address: 'tb1qa8fuxpg0f8sp8c8yynw9wnuzh9kdcx0nyvu6z6',
    //     chainIndex: 1,
    //     keyIndex: 0,
    //     timestamp: DateTime.now().millisecondsSinceEpoch ~/1000,
    //     locked: false,
    //     decimals: 8));
    // _utxos.add(_changeUtxo);
    // return _utxos.map((utxo) => UnspentTxOut.fromUtxoEntity(utxo)).toList();
    // TEST(END)
  }

  @override
  Future<List> publishTransaction(
      String blockchainId, Transaction transaction) async {
    APIResponse response = await HTTPAgent().post(
        '${Endpoint.url}/blockchain/$blockchainId/push-tx',
        {"hex": hex.encode(transaction.serializeTransaction)});
    bool success = response.success;
    BitcoinTransaction? _transaction;
    if (success) {
      // updateUsedUtxo
      _transaction = transaction as BitcoinTransaction;
      _transaction.id = response.data['txid'];
      _transaction.txId = response.data['txid'];
      _transaction.timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      _transaction.confirmations = 0;
      _transaction.message = transaction.message ?? Uint8List(0);
      _transaction.direction = transaction.direction;
      _transaction.status = transaction.status ?? TransactionStatus.pending;
      transaction.inputs.forEach((Input input) async {
        UnspentTxOut _utxo = input.utxo;
        _utxo.locked = true;
        await DBOperator()
            .utxoDao
            .insertUtxo(UtxoEntity.fromUnspentUtxo(_utxo));
      });
      // insertChangeUtxo
      if (transaction.changeUtxo != null) {
        Log.debug('changeUtxo txId: ${transaction.changeUtxo!.txId}');
        await DBOperator()
            .utxoDao
            .insertUtxo(UtxoEntity.fromUnspentUtxo(transaction.changeUtxo!));
        Log.debug('changeUtxo amount: ${transaction.changeUtxo!.amount}');
      }
      // backend will parse transaction and insert changeUtxo to backend DB
    }

    return [success, _transaction]; // TODO return transaction
  }

  Future _syncUTXO() async {
    int now = DateTime.now().millisecondsSinceEpoch;

    if (now - this.service.lastSyncTimestamp! > this.syncInterval) {
      Log.btc('_syncUTXO');
      String currencyId = this.service.shareAccountId;
      Log.btc('_syncUTXO currencyId: $currencyId');

      APIResponse response = await HTTPAgent()
          .get('${Endpoint.url}/wallet/account/txs/uxto/$currencyId');
      if (response.success) {
        List<dynamic> datas = response.data;
        List<UtxoEntity> utxos =
            datas.map((data) => UtxoEntity.fromJson(currencyId, data)).toList();
        DBOperator().utxoDao.insertUtxos(utxos);
      } else {
        // TODO
      }
    }
  }

  @override
  Future synchro({bool? force}) async {
    await this.service.synchro(force: force);
    await this._syncUTXO();
  }

  @override
  Future updateTransaction(String currencyId, Map payload) {
    return this.service.updateTransaction(currencyId, payload);
  }

  Future<List<int>> updateUTXO(String currencyId, List data) {
    List<UtxoEntity> utxos =
        data.map((data) => UtxoEntity.fromJson(currencyId, data)).toList();
    return DBOperator().utxoDao.insertUtxos(utxos);
  }

  @override
  Future updateAccount(String currencyId, Map payload) {
    return this.service.updateAccount(currencyId, payload);
  }
}
