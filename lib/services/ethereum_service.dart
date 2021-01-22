import 'dart:async';
import 'package:tidewallet3/constants/account_config.dart';

import 'account_service_decorator.dart';

import 'package:decimal/decimal.dart';
import 'package:tidewallet3/models/account.model.dart';
import 'package:tidewallet3/services/account_service.dart';
import '../mock/endpoint.dart';
import '../cores/account.dart';

class EthereumService extends AccountServiceDecorator {
  EthereumService(AccountService service) : super(service);

  Timer _timer;

  estimateGasLimit() {}
  getTransactions() {}
  getBalance() {}
  getTokenTransactions() {}
  getTokenBalance() {}
  getTokenInfo() {}

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
  void init() {
    // TODO: implement init
  }

  @override
  prepareTransaction() {
    // TODO: implement prepareTransaction
    throw UnimplementedError();
  }

  @override
  void start() {
    this._sync();
  }

  @override
  void stop() {
    _timer?.cancel();
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

  _sync() {
    _timer =
        Timer.periodic(Duration(milliseconds: this.syncInterval), (_) async {
      await this._getTokens();
      Currency curr = await this._getETH();

      String _fiat = AccountCore().getAccountFiat(curr.accountType);

      AccountMessage msg = AccountMessage(
          evt: ACCOUNT_EVT.OnUpdateAccount, value: curr.copyWith(fiat: _fiat));
      AccountCore().messenger.add(msg);
    });
  }

  _getTokens() async {
    List<Map> result = await getETHTokens();
    List<Currency> tokenList = result.map((e) => Currency.fromMap(e)).toList();

    AccountCore().currencies[ACCOUNT.ETH] =
        AccountCore().currencies[ACCOUNT.ETH].sublist(0, 1) + tokenList;
  }

  Future<Currency> _getETH() async {
    Map res = await getETH();
    Currency curr = Currency.fromMap({...res, "accountType": ACCOUNT.ETH});
    AccountCore().currencies[curr.accountType][0] = curr;
    return curr;
  }
}
