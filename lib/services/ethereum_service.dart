import 'dart:async';
import 'package:decimal/decimal.dart';

import 'account_service_decorator.dart';
import '../models/account.model.dart';
import '../models/transaction.model.dart';
import '../constants/account_config.dart';
import '../services/account_service.dart';
import '../mock/endpoint.dart';
import '../helpers/logger.dart';

class EthereumService extends AccountServiceDecorator {
  EthereumService(AccountService service) : super(service) {
    this.base = ACCOUNT.ETH;
    this.syncInterval = 5 * 60 * 1000;
  }

  @override
  Decimal calculateFastDee() {
    // TODO: implement calculateFastDee
    throw UnimplementedError();
  }

  @override
  Decimal calculateSlowDee() {
    // TODO: implement calculateSlowDee
    throw UnimplementedError();
  }

  @override
  Decimal calculateStandardDee() {
    // TODO: implement calculateStandardDee
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

  @override
  publishTransaction() {
    // TODO: implement publishTransaction
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
  Future<String> getReceivingAddress() async {
    // TODO: implement publishTransaction
    throw UnimplementedError();
  }

  @override
  getTransactions() {
    // TODO: implement getTransactions
    throw UnimplementedError();
  }
}
