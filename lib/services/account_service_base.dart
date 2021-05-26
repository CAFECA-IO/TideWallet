import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:tidewallet3/helpers/logger.dart';

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
import '../models/transaction.model.dart';
import 'account_service.dart';

class AccountServiceBase extends AccountService {
  ACCOUNT _base;
  String _accountId;
  int _syncInterval;
  int _lastSyncTimestamp;

  get base => this._base;
  get lastSyncTimestamp => this._lastSyncTimestamp;
  get accountId => this._accountId;

  AccountServiceBase();

  @override
  void init(String id, ACCOUNT base, {int interval}) {
    this._accountId = id;
    this._base = base;
    this._syncInterval = interval ?? this._syncInterval;
  }

  @override
  Future start() async {
    AccountCurrencyEntity select = await DBOperator()
        .accountCurrencyDao
        .findOneByAccountyId(this._accountId);

    await this._pushResult();
    await this._getSupportedToken();
    // await this._getSettingTokens();

    if (select != null) {
      this._lastSyncTimestamp = select.lastSyncTime;
    } else {
      this._lastSyncTimestamp = 0;
    }
  }

  @override
  void stop() {
    this.timer?.cancel();
  }

  @override
  Future<Map<TransactionPriority, Decimal>> getTransactionFee(
      String blockchainId) async {
    throw UnimplementedError('Implement on decorator');
  }

  Future<List> getData() async {
    APIResponse res = await HTTPAgent()
        .get(Endpoint.url + '/wallet/account/${this._accountId}');
    final acc = res.data;

    if (acc != null) {
      List<dynamic> tks = acc['tokens'];
      List<CurrencyEntity> _currs =
          await DBOperator().currencyDao.findAllCurrencies();
      tks.forEach((token) async {
        int index =
            _currs.indexWhere((_curr) => _curr.currencyId == token['token_id']);

        if (index < 0) {
          APIResponse res = await HTTPAgent().get(Endpoint.url +
              '/blockchain/${token['blockchain_id']}/token/${token['token_id']}');
          if (res.data != null) {
            Map token = res.data;
            await DBOperator()
                .currencyDao
                .insertCurrency(CurrencyEntity.fromJson(token));
          }
        }
      });

      return [acc] + tks;
    }

    return [];
  }

  synchro({bool force}) async {
    int now = DateTime.now().millisecondsSinceEpoch;

    if (now - this._lastSyncTimestamp > this._syncInterval || force == true) {
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

    // AccountMessage msg =
    //     AccountMessage(evt: ACCOUNT_EVT.OnUpdateAccount, value: cs[0]);
    AccountCore().currencies[this._accountId] = cs;

    AccountMessage currMsg = AccountMessage(
        evt: ACCOUNT_EVT.OnUpdateCurrency,
        value: AccountCore().currencies[this._accountId]);

    // AccountCore().messenger.add(msg);
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
        .get(Endpoint.url + '/blockchain/${acc.networkId}/token');

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
        .get(Endpoint.url + '/wallet/account/txs/${currency.id}');

    if (res.success) {
      List txs = res.data;
      txs =
          txs.map((tx) => TransactionEntity.fromJson(currency.id, tx)).toList();

      await DBOperator().transactionDao.insertTransactions(txs);
    }
    return this._loadTransactions(currency.id);
  }

  Future<List<TransactionEntity>> _loadTransactions(String currencyId) async {
    List<TransactionEntity> transactions =
        await DBOperator().transactionDao.findAllTransactionsById(currencyId);

    List<TransactionEntity> _transactions1 = transactions
        .where((transaction) => transaction.timestamp == null)
        .toList();
    List<TransactionEntity> _transactions2 = transactions
        .where((transaction) => transaction.timestamp != null)
        .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return (_transactions1 + _transactions2);
  }

  @override
  Future<List> getChangingAddress(String currencyId) {
    throw UnimplementedError('Implement on decorator');
  }

  @override
  Future<List> getReceivingAddress(String currencyId) {
    throw UnimplementedError('Implement on decorator');
  }

  @override
  Future<List> publishTransaction(
      String blockchainId, Transaction transaction) {
    throw UnimplementedError('Implement on decorator');
  }

  Future updateTransaction(String currencyId, Map payload) async {
    List<Currency> currencies = AccountCore().currencies[this.accountId];
    TransactionEntity txEntity =
        TransactionEntity.fromJson(currencyId, payload);

    Currency currency =
        currencies.firstWhere((c) => c.currencyId == currencyId);
    AccountMessage txMsg = AccountMessage(
      evt: ACCOUNT_EVT.OnUpdateTransaction,
      value: {
        "currency": currency,
        "transaction": Transaction.fromTransactionEntity(txEntity)
      },
    );
    AccountCore().messenger.add(txMsg);
    await DBOperator().transactionDao.insertTransaction(txEntity);
  }

  Future updateCurrency(String currencyId, Map payload) async {
    List<AccountCurrencyEntity> acs =
        await DBOperator().accountCurrencyDao.findAllCurrencies();

    AccountCurrencyEntity ac =
        acs.firstWhere((a) => a.currencyId == currencyId);

    AccountCurrencyEntity updated = AccountCurrencyEntity(
      accountcurrencyId: ac.accountcurrencyId,
      accountId: this._accountId,
      currencyId: ac.currencyId,
      balance: '${payload['balance']}',
      numberOfUsedExternalKey: ac.numberOfUsedExternalKey,
      numberOfUsedInternalKey: ac.numberOfUsedInternalKey,
      lastSyncTime: DateTime.now().millisecondsSinceEpoch,
    );

    await DBOperator().accountCurrencyDao.insertAccount(updated);

    this._pushResult();
  }

  // _getSettingTokens() async {
  //   AccountEntity acc =
  //       await DBOperator().accountDao.findAccount(this._accountId);
  //     Log.warning(acc.networkId);
  //   APIResponse response = await HTTPAgent()
  //       .get('${Endpoint.url}/blockchain/${acc.networkId}/token?type=TideWallet');

  //   if (response.success) {
  //     List<DisplayCurrency> ds = [...response.data].map((tk) {
  //       return DisplayCurrency(
  //           symbol: tk['symbol'],
  //           name: tk['name'],
  //           icon: tk['icon'],
  //           currencyId: tk['currency_id'],
  //           contract: tk['contract']
  //      );
  //     }).toList();
  //     AccountCore().settingOptions[this._accountId] = ds;
  //   }
  // }
}
