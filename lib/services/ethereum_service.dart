import 'dart:async';
import 'package:tidewallet3/constants/account_config.dart';

import 'account_service_decorator.dart';

import 'package:decimal/decimal.dart';
import 'package:tidewallet3/models/account.model.dart';
import 'package:tidewallet3/services/account_service.dart';
import '../mock/endpoint.dart';
import '../cores/account.dart';
import '../models/transaction.model.dart';

class EthereumService extends AccountServiceDecorator {
  EthereumService(AccountService service) : super(service) {
    this.base = ACCOUNT.ETH;
  }
  
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


      AccountMessage msg = AccountMessage(
          evt: ACCOUNT_EVT.OnUpdateAccount, value: curr);

      AccountMessage currMsg = AccountMessage(
          evt: ACCOUNT_EVT.OnUpdateCurrency, value: AccountCore().currencies[this.base]);
      
      AccountCore().messenger.add(msg);
      AccountCore().messenger.add(currMsg);

      List<Transaction> transactions = await this._getTransactions();

      AccountMessage txMsg = AccountMessage(evt: ACCOUNT_EVT.OnUpdateTransactions, value: {
        "currency": curr,
        "transactions": transactions
      });
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
    Map result = await getETHTokeninfo(_address);
    if (result != null && result['success']) {
      Token _token = Token(
          symbol: result['symbol'],
          name: result['name'],
          decimal: result['decimal'],
          imgUrl: result['imgPath'],
          description: result['description'],
          contract: result['contract'],
          totalSupply: result['totalSupply']
          );
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
}
