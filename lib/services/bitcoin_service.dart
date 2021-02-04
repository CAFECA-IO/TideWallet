import 'dart:async';
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';

import 'account_service.dart';
import 'account_service_decorator.dart';
import '../models/transaction.model.dart';
import '../helpers/logger.dart';
import '../helpers/utils.dart';
import '../helpers/http_agent.dart';
import '../constants/account_config.dart';

class BitcoinService extends AccountServiceDecorator {
  String _accountId; //TODO TEST
  BitcoinService(AccountService service) : super(service) {
    this.base = ACCOUNT.BTC;
    _accountId = 'cfc3324'; //TODO TEST
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
  publishTransaction() {
    // TODO: implement publishTransaction
    throw UnimplementedError();
  }

  @override
  Future<Decimal> estimateGasLimit(String hex) {
    // TODO: implement estimateGasLimit
    throw UnimplementedError();
  }

  @override
  Future<List<dynamic>> getTransactionFee(String hex) async {
    // TODO getFeeFromDB && getSyncFeeAutomatically
    Response response =
        await HTTPAgent().get('$_baseUrl/api/v1/blockchain/80000001/fee');
    Map<String, dynamic> data =
        response.data['payload']; // TODO FEE should return String or double
    // TODO calculateTransactionVsize
    Map<TransactionPriority, Decimal> transactionFee = {
      TransactionPriority.slow: Decimal.parse(data['slow'].toString()),
      TransactionPriority.standard: Decimal.parse(data['standard'].toString()),
      TransactionPriority.fast: Decimal.parse(data['fast'].toString()),
    };
    return [transactionFee];
  }

  @override
  Future<String> getChangingAddress() async {
    Response response = await HTTPAgent()
        .get('$_baseUrl/api/v1/wallet/account/address/$_accountId/change');
    Map data = response.data['payload'];
    String _address = data['address'];
    _numberOfUsedInternalKey = data['change_index'];
    return _address;
  }

  @override
  Future<String> getReceivingAddress() async {
    Response response = await HTTPAgent()
        .get('$_baseUrl/api/v1/wallet/account/address/$_accountId/receive');
    Map data = response.data['payload'];
    String address = data['address'];
    _numberOfUsedExternalKey = data['key_index'];
    return address;
  }
}
