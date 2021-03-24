import 'dart:async';

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

import 'dart:typed_data'; //TODO TEST
import '../cores/paper_wallet.dart'; //TODO TEST
import '../helpers/bitcoin_based_utils.dart'; //TODO TEST

class BitcoinService extends AccountServiceDecorator {
  BitcoinService(AccountService service) : super(service) {
    this.base = ACCOUNT.BTC;
    this.syncInterval = 10 * 60 * 1000;
    // this.path = "m/44'/0'/0'";
  }
  int _numberOfUsedExternalKey;
  int _numberOfUsedInternalKey;
  int _lastSyncTimestamp;
  Map<TransactionPriority, Decimal> _fee;
  int _timestamp; // fetch transactionFee timestamp;

  @override
  void init(String id, ACCOUNT base, {int interval}) {
    this.service.init(id, base ?? this.base, interval: this.syncInterval);
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

  @override
  Future<Map<TransactionPriority, Decimal>> getTransactionFee(
      String blockchainId) async {
    // TODO getSyncFeeAutomatically
    if (_fee == null ||
        DateTime.now().millisecondsSinceEpoch - _timestamp >
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

        _timestamp = DateTime.now().millisecondsSinceEpoch;
      } else {
        // TODO fee = null 前面會出錯
      }
    }

    return _fee;
  }

  @override
  Future<List> getChangingAddress(String currencyId) async {
    APIResponse response = await HTTPAgent()
        .get('${Endpoint.SUSANOO}/wallet/account/address/$currencyId/change');
    if (response.success) {
      Map data = response.data;
      String _address = data['address'];
      _numberOfUsedInternalKey = data['key_index'];
      return [_address, _numberOfUsedInternalKey];
    } else {
      //TODO
      return ['error', 0];
    }
  }

  @override
  Future<List> getReceivingAddress(String currencyId) async {
    APIResponse response = await HTTPAgent()
        .get('${Endpoint.SUSANOO}/wallet/account/address/$currencyId/receive');
    if (response.success) {
      Map data = response.data;
      String address = data['address'];
      _numberOfUsedExternalKey = data['key_index'];
      Log.debug('api address: $address');
      Log.debug('api keyIndex: $_numberOfUsedExternalKey');
      String seed =
          'fc7cc8e276203c73099923e0995ed4d5b66edfc900e017bd488b30d44e0d21bc';
      Uint8List publicKey = await PaperWallet.getPubKey(
          hex.decode(seed), 0, _numberOfUsedExternalKey);
      String calAddress = pubKeyToP2wpkhAddress(publicKey, 'tb');
      Log.debug('calculated address: $calAddress');
      return [address, _numberOfUsedExternalKey];
    } else {
      //TODO
      return ['error', 0];
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
        '${Endpoint.SUSANOO}/blockchain/$blockchainId/push-tx',
        {"hex": hex.encode(transaction.serializeTransaction)});
    bool success = response.success;
    BitcoinTransaction _transaction;
    if (success) {
      // updateUsedUtxo
      _transaction = transaction;
      _transaction.id = response.data['txid'];
      _transaction.txId = response.data['txid'];
      _transaction.timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      _transaction.confirmations = 0;
      _transaction.message = transaction.message ?? Uint8List(0);
      _transaction.direction =
          transaction.direction ?? TransactionDirection.sent;
      _transaction.status = transaction.status ?? TransactionStatus.pending;
      _transaction.inputs.forEach((Input input) async {
        UnspentTxOut _utxo = input.utxo;
        _utxo.locked = true;
        await DBOperator()
            .utxoDao
            .insertUtxo(UtxoEntity.fromUnspentUtxo(_utxo));
      });
      // insertChangeUtxo
      if (transaction.changeUtxo != null) {
        await DBOperator()
            .utxoDao
            .insertUtxo(UtxoEntity.fromUnspentUtxo(transaction.changeUtxo));
      }
      // backend will parse transaction and insert changeUtxo to backend DB
    }

    return [success, _transaction]; // TODO return transaction
  }

  Future _syncUTXO() async {
    int now = DateTime.now().millisecondsSinceEpoch;

    if (now - this.service.lastSyncTimestamp > this.syncInterval) {
      Log.btc('_syncUTXO');
      String currencyId = this.service.accountId;
      Log.btc('_syncUTXO currencyId: $currencyId');

      APIResponse response = await HTTPAgent()
          .get('${Endpoint.SUSANOO}/wallet/account/txs/uxto/$currencyId');
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
  Future synchro() async {
    await this.service.synchro();
    await this._syncUTXO();
  }
}
