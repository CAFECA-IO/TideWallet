import 'dart:async';

import 'package:decimal/decimal.dart';

import '../constants/endpoint.dart';
import '../constants/account_config.dart';
import '../cores/account.dart';
import '../database/db_operator.dart';
import '../database/entity/account_currency.dart';
import '../database/entity/account.dart';
import '../database/entity/currency.dart';
import '../database/entity/transaction.dart';
import '../helpers/http_agent.dart';
import '../models/account.model.dart';
import '../models/api_response.mode.dart';
import '../models/utxo.model.dart';
import '../models/transaction.model.dart';
import 'account_service.dart';

import '../helpers/logger.dart';

class AccountServiceBase extends AccountService {
  Timer _timer;
  ACCOUNT _base;
  String _accountId;
  int _syncInterval;
  int _lastSyncTimestamp;

  get base => this._base;
  get lastSyncTimestamp => this._lastSyncTimestamp;
  get accountId => this._accountId;

  AccountServiceBase();

  @override
  Decimal calculateFastFee() {
    // TODO: implement calculateFastFee
    throw UnimplementedError();
  }

  @override
  Decimal calculateSlowFee() {
    // TODO: implement calculateSlowFee
    throw UnimplementedError();
  }

  @override
  Decimal calculateStandardFee() {
    // TODO: implement calculateStandardFee
    throw UnimplementedError();
  }

  @override
  getTransactions() {
    // TODO: implement getTransactions
    throw UnimplementedError();
  }

  @override
  void init(String id, ACCOUNT base, {int interval}) {
    this._accountId = id;
    this._base = base;
    this._syncInterval = interval ?? this._syncInterval;
  }

  @override
  prepareTransaction() {
    // TODO: implement prepareTransaction
    throw UnimplementedError();
  }

  @override
  Future start() async {
    AccountCurrencyEntity select = await DBOperator()
        .accountCurrencyDao
        .findOneByAccountyId(this._accountId);

    await this._pushResult();
    await this._getSupportedToken();

    if (select != null) {
      this._lastSyncTimestamp = select.lastSyncTime;
    } else {
      this._lastSyncTimestamp = 0;
    }

    _sync();

    _timer = Timer.periodic(Duration(milliseconds: this._syncInterval), (_) {
      _sync();
    });
  }

  @override
  void stop() {
    _timer?.cancel();
  }

  @override
  Decimal toCoinUnit(Decimal smallUnit) {
    // TODO: implement toCoinUnit
    throw UnimplementedError();
  }

  @override
  Decimal toSmallUnit(Decimal coinUnit) {
    // TODO: implement toSmallUnit
    throw UnimplementedError();
  }

  @override
  Future<Map<TransactionPriority, Decimal>> getTransactionFee(
      String blockchainId) async {
    // TODO: implement publishTransaction
    throw UnimplementedError();
  }

  Future<List> getData() async {
    APIResponse res = await HTTPAgent()
        .get(Endpoint.SUSANOO + '/wallet/account/${this._accountId}');
    final acc = res.data;

    if (acc != null) {
      List tks = acc['tokens'];

      // CurrencyEntity.Currency.fromJson(acc);

      // final result = [Currency.fromMap(acc)] +
      //     tks.map((e) => Currency.fromMap({...e, 'accountType': this.base, 'accountId': this.accountId})).toList();

      return [acc] + tks;
    }

    return [];
  }

  _sync() async {
    int now = DateTime.now().millisecondsSinceEpoch;

    if (now - this._lastSyncTimestamp > this._syncInterval) {
      List currs = await this.getData();
      final v = currs
          .map((c) => AccountCurrencyEntity.fromJson(c, this._accountId, now))
          .toList();

      await DBOperator().accountCurrencyDao.insertCurrencies(v);
    }

    await this._pushResult();
    await this._syncTransactions();
  }

  Future _pushResult() async {
    List<JoinCurrency> jcs = await DBOperator()
        .accountCurrencyDao
        .findJoinedByAccountId(this._accountId);

    if (jcs.isEmpty) return;

    List<Currency> cs = jcs
        .map(
          (c) => Currency.fromJoinCurrency(c, jcs[0], this._base),
        )
        .toList();

    AccountMessage msg =
        AccountMessage(evt: ACCOUNT_EVT.OnUpdateAccount, value: cs[0]);
    AccountCore().currencies[this._accountId] = cs;

    AccountMessage currMsg = AccountMessage(
        evt: ACCOUNT_EVT.OnUpdateCurrency,
        value: AccountCore().currencies[this._accountId]);

    AccountCore().messenger.add(msg);
    AccountCore().messenger.add(currMsg);
  }

  Future _getSupportedToken() async {
    final tokens = await DBOperator()
        .currencyDao
        .findAllCurrenciesByAccountId(this._accountId);
    if (tokens.isNotEmpty) return;
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

  Future _syncTransactions() async {
    final currencies = AccountCore().currencies[this._accountId];

    for (var currency in currencies) {
      final transactions = await this._getTransactions(currency);
      AccountMessage txMsg =
          AccountMessage(evt: ACCOUNT_EVT.OnUpdateTransactions, value: {
        "currency": currency,
        "transactions": transactions
            .map((tx) => Transaction.fromTransactionEntity(tx))
            .toList()
      });
      AccountCore().messenger.add(txMsg);
    }
  }

  Future<List<TransactionEntity>> _getTransactions(Currency currency) async {
    APIResponse res = await HTTPAgent()
        .get(Endpoint.SUSANOO + '/wallet/account/txs/${currency.id}');

    if (res.success) {
      List txs = res.data;
      txs =
          txs.map((tx) => TransactionEntity.fromJson(currency.id, tx)).toList();

      await DBOperator().transactionDao.insertTransactions(txs);
    }
    return this._loadTransactions(currency.id);
  }

  Future<List<TransactionEntity>> _loadTransactions(String currencyId) async {
    return await DBOperator().transactionDao.findAllTransactionsById(currencyId)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Future<Decimal> estimateGasLimit(
      String blockchainId, String from, String to, String amount, String data) {
    // TODO: implement estimateGasLimit
    throw UnimplementedError();
  }

  @override
  Future<List> getChangingAddress(String currencyId) {
    // TODO: implement getChangingAddress
    throw UnimplementedError();
  }

  @override
  Future<int> getNonce(String blockchainId, String address) {
    // TODO: implement getNonce
    throw UnimplementedError();
  }

  @override
  Future<List> getReceivingAddress(String currencyId) {
    // TODO: implement getReceivingAddress
    throw UnimplementedError();
  }

  @override
  Future<List<UnspentTxOut>> getUnspentTxOut(String currencyId) {
    // TODO: implement getUnspentTxOut
    throw UnimplementedError();
  }

  @override
  Future<List> publishTransaction(
      String blockchainId, Transaction transaction) {
    // TODO: implement publishTransaction
    throw UnimplementedError();
  }
}
