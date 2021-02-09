import 'dart:async';

import 'package:decimal/decimal.dart';
import '../constants/endpoint.dart';
import '../cores/account.dart';
import '../database/db_operator.dart';
import '../database/entity/account_currency.dart';
import '../helpers/http_agent.dart';
import '../models/account.model.dart';
import '../models/api_response.mode.dart';

import '../constants/account_config.dart';
import '../services/account_service.dart';
import '../helpers/logger.dart';
import '../database/entity/account.dart';
import '../database/entity/currency.dart';


import 'account_service.dart';

class AccountServiceBase extends AccountService {
  Timer _timer;
  String _accountId;
  AccountServiceBase();

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
  getTransactions() {
    // TODO: implement getTransactions
    throw UnimplementedError();
  }

  @override
  void init(String id, ACCOUNT base, { int interval }) {
    this._accountId = id;
    this.base = base;
    this.syncInterval = interval ?? this.syncInterval;
  }

  @override
  prepareTransaction() {
    // TODO: implement prepareTransaction
    throw UnimplementedError();
  }

  @override
  void start() async {
    await this._getSuppertedToken();
    _sync();
    _timer = Timer.periodic(Duration(milliseconds: this.syncInterval), (_) {
      _sync();
    });
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

  @override
  Future<String> getReceivingAddress() async {
    // TODO: implement publishTransaction
    throw UnimplementedError();
  }

  Future<List> getData() async {
    APIResponse res = await HTTPAgent()
        .get(Endpoint.SUSANOO + '/wallet/account/${this._accountId}');
    if (res.data == null) return [];
    final acc = res.data[0];
    List tks = acc['tokens'];

    // CurrencyEntity.Currency.fromJson(acc);

    // final result = [Currency.fromMap(acc)] +
    //     tks.map((e) => Currency.fromMap({...e, 'accountType': this.base, 'accountId': this.accountId})).toList();

    return [acc] + tks;
  }

  _sync() async {
    List currs = await this.getData();
    int now = DateTime.now().millisecondsSinceEpoch;


    final v = currs
        .map(
          (c) => AccountCurrencyEntity(
              accountcurrencyId: c['currency_id'] ?? c['token_id'],
              accountId: this._accountId,
              numberOfUsedExternalKey: c['number_of_external_key'],
              numberOfUsedInternalKey: c['number_of_internal_key'],
              balance: c['balance'],
              currencyId: c['currency_id'] ?? c['token_id'],
              lastSyncTime: now),
        )
        .toList();

    await DBOperator().accountCurrencyDao.insertCurrencies(v);
    List<JoinCurrency> jcs =
        await DBOperator().accountCurrencyDao.findByAccountyId(this._accountId);

    List cs = jcs
        .map(
          (c) => Currency(
            accountIndex: c.accountIndex,
            accountType: this.base,
            cointype: c.coinType,
            amount: c.balance,
            imgPath: c.image,
            symbol: c.symbol,
          ),
        )
        .toList();

    AccountMessage msg =
        AccountMessage(evt: ACCOUNT_EVT.OnUpdateAccount, value: cs[0]);
    AccountCore().currencies[this.base] = cs;

    AccountMessage currMsg = AccountMessage(
        evt: ACCOUNT_EVT.OnUpdateCurrency,
        value: AccountCore().currencies[this.base]);

    Log.debug(AccountCore().currencies[this.base]);
    AccountCore().messenger.add(msg);
    AccountCore().messenger.add(currMsg);
  }

  Future _getSuppertedToken() async {
    Log.error(this._accountId);
    AccountEntity acc =
        await DBOperator().accountDao.findAccount(this._accountId);

    APIResponse res = await HTTPAgent()
        .get(Endpoint.SUSANOO + '/blockchain/${acc.networkId}/token');

    if (res.data != null) {
      List tokens = res.data;
      tokens = tokens.map((t) => CurrencyEntity.fromJson(t)).toList();
      await DBOperator().currencyDao.insertCurrencies(tokens);
    }
  }
}
