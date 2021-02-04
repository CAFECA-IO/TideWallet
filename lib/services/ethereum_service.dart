import 'dart:async';
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';

import 'account_service_decorator.dart';
import '../models/account.model.dart';
import '../models/transaction.model.dart';
import '../constants/account_config.dart';
import '../services/account_service.dart';
import '../mock/endpoint.dart';
import '../cores/account.dart';
import '../helpers/http_agent.dart';

class EthereumService extends AccountServiceDecorator {
  EthereumService(AccountService service) : super(service) {
    this.base = ACCOUNT.ETH;
  }
  static const String _baseUrl = 'https://service.tidewallet.io';

  Timer _timer;

  Future<Map<TransactionPriority, Decimal>> getGasPrice() async {
    Response response =
        await HTTPAgent().get('$_baseUrl/api/v1/blockchain/8000003C/fee');
    Map<String, dynamic> data =
        response.data['payload']; // TODO FEE should return String or double
  }

  getTransactions() {}
  getBalance() {}
  getTokenTransactions() {}
  getTokenBalance() {}
  getTokenInfo() {}

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
    this._sync();
  }

  @override
  void stop() {
    _timer?.cancel();
  }

  // @override
  // Decimal toCoinUnit(Decimal wei) {
  //   // TODO: implement toCoinUnit
  //   throw UnimplementedError();
  // }

  // @override
  // Decimal toSmallUnit(Decimal eth) {
  //   // TODO: implement toSmallUnit
  //   throw UnimplementedError();
  // }

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

      AccountMessage msg =
          AccountMessage(evt: ACCOUNT_EVT.OnUpdateAccount, value: curr);

      AccountMessage currMsg = AccountMessage(
          evt: ACCOUNT_EVT.OnUpdateCurrency,
          value: AccountCore().currencies[this.base]);

      AccountCore().messenger.add(msg);
      AccountCore().messenger.add(currMsg);

      List<Transaction> transactions = await this._getTransactions();

      AccountMessage txMsg = AccountMessage(
          evt: ACCOUNT_EVT.OnUpdateTransactions,
          value: {"currency": curr, "transactions": transactions});
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

  Future<Decimal> _estimateGasLimit(String hex) async {
    Response response = await HTTPAgent().post(
        '$_baseUrl/api/v1/blockchain/8000003C/gas-limit',
        {'hex': hex}); // TODO API FormatError
    Map<String, dynamic> data = response.data['payload'];
    int gasLimit = data['gasLimit'];
    return Decimal.fromInt(gasLimit);
  }

  @override
  Future<List<dynamic>> getTransactionFee(String hex) async {
    // TODO getFeeFromDB && getSyncFeeAutomatically
    Response response =
        await HTTPAgent().get('$_baseUrl/api/v1/blockchain/8000003C/fee');
    Map<String, dynamic> data =
        response.data['payload']; // TODO FEE should return String or double
    Map<TransactionPriority, Decimal> transactionFee = {
      TransactionPriority.slow: Decimal.parse(data['slow'].toString()),
      TransactionPriority.standard: Decimal.parse(data['standard'].toString()),
      TransactionPriority.fast: Decimal.parse(data['fast'].toString()),
    };
    Decimal gasLimit = await _estimateGasLimit(hex);
    return [transactionFee, gasLimit];
  }

  @override
  Future<String> getReceivingAddress() async {
    // TODO: implement publishTransaction
    throw UnimplementedError();
  }

  @override
  Future<String> getChangingAddress() async {
    // TODO: implement publishTransaction
    throw UnimplementedError();
  }
}
