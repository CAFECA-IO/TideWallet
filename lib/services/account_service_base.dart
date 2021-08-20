import 'dart:async';

import 'package:decimal/decimal.dart';

import '../constants/endpoint.dart';
import '../constants/account_config.dart';
import '../cores/account.dart';
import '../cores/trader.dart';
import '../database/db_operator.dart';
import '../database/entity/account.dart';
import '../database/entity/currency.dart';
import '../database/entity/transaction.dart';
import '../helpers/http_agent.dart';
import '../models/account.model.dart';
import '../models/api_response.mode.dart';
import '../models/transaction.model.dart';
import '../helpers/logger.dart';
import 'account_service.dart';

class AccountServiceBase extends AccountService {
  ACCOUNT? _base;
  String? _shareAccountId;
  int? _syncInterval;
  int? _lastSyncTimestamp;
  Timer? _timer;

  ACCOUNT get base => this._base!;
  int get lastSyncTimestamp => this._lastSyncTimestamp!;
  String get shareAccountId => this._shareAccountId!;

  Timer get timer => this._timer!;
  set timer(Timer timer) => this._timer = timer;

  AccountServiceBase();

  @override
  void init(String id, ACCOUNT base, {int? interval}) {
    this._shareAccountId = id;
    this._base = base;
    this._syncInterval = interval ?? this.syncInterval;
  }

  @override
  Future start() async {
    Log.debug('start this.shareAccountId: ${this.shareAccountId}');

    AccountEntity? _acc =
        await DBOperator().accountDao.findAccount(this.shareAccountId);
    Log.debug(
        "start _acc.id: ${_acc?.id}, _acc.shareAccountId: ${_acc?.shareAccountId}, _acc.blockchainId: ${_acc?.blockchainId}, _acc.currencyId: ${_acc?.currencyId},  _acc.balance: ${_acc?.balance}");
    await this._pushResult();
    this._lastSyncTimestamp = _acc?.lastSyncTime;
  }

  @override
  void stop() {
    this.timer.cancel();
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
    throw UnimplementedError('Implement on decorator');
  }

  Future<List<AccountEntity>> getData() async {
    List<AccountEntity> accounts = [];
    AccountEntity? accountEntity =
        await DBOperator().accountDao.findAccount(this.shareAccountId);
    APIResponse res = await HTTPAgent()
        .get(Endpoint.url + '/wallet/account/${this.shareAccountId}');
    final acc = res.data;

    if (acc != null && accountEntity != null) {
      AccountEntity _mainAccount = accountEntity.copyWith(
          balance: acc['balance'],
          numberOfUsedExternalKey: acc["number_of_used_external_key"] ?? 0,
          numberOfUsedInternalKey: acc["number_of_used_internal_key"] ?? 0,
          lastSyncTime: this._lastSyncTimestamp);
      accounts.add(_mainAccount);
      List<dynamic> tks = acc['tokens'];
      List<CurrencyEntity> _currs =
          await DBOperator().currencyDao.findAllCurrencies();
      tks.forEach((token) async {
        AccountEntity _tokenAccount = _mainAccount.copyWith(
            id: token['account_token_id'],
            currencyId: token['token_id'],
            balance: token['balance']);
        accounts.add(_tokenAccount);
        int index =
            _currs.indexWhere((_curr) => _curr.currencyId == token['token_id']);
        Log.debug('getData index: $index');
        if (index < 0) {
          APIResponse res = await HTTPAgent().get(Endpoint.url +
              '/blockchain/${token['blockchain_id']}/token/${token['token_id']}');
          Log.debug('getData res: $res');

          if (res.data != null) {
            Map token = res.data;
            await DBOperator()
                .currencyDao
                .insertCurrency(CurrencyEntity.fromJson(token));
          }
        }
      });

      return accounts;
    }

    return accounts;
  }

  synchro({bool? force}) async {
    int now = DateTime.now().millisecondsSinceEpoch;

    if (this._lastSyncTimestamp == null ||
        now - this._lastSyncTimestamp! > this.syncInterval ||
        force == true) {
      this._lastSyncTimestamp = now;
      List<AccountEntity> accounts = await this.getData();
      await DBOperator().accountDao.insertAccounts(accounts);
    }

    await this._pushResult();
    await this._syncTransactions();
  }

  Future _pushResult() async {
    List<JoinAccount> jaccs = await DBOperator()
        .accountDao
        .findJoinedAccountsByShareAccountId(this.shareAccountId);
    if (jaccs.isEmpty) return;

    List<Account> accs = [];

    Fiat fiat = await Trader().getSelectedFiat();

    for (JoinAccount jacc in jaccs) {
      Account acc =
          Account.fromJoinAccount(jacc).copyWith(accountType: this.base);
      acc.inFiat = await Trader().calculateToFiat(acc, fiat: fiat);
      accs.add(acc);
    }

    AccountCore().accounts[this.shareAccountId] = accs;
    Map data = AccountCore().getOverview();

    AccountMessage currMsg = AccountMessage(
      evt: ACCOUNT_EVT.OnUpdateAccount,
      value: data,
    );

    AccountCore().messenger.add(currMsg);
  }

  Future _syncTransactions() async {
    final List<Account> accounts = AccountCore().accounts[this.shareAccountId]!;

    for (Account account in accounts) {
      final transactions = await this._getTransactions(account);
      AccountMessage txMsg =
          AccountMessage(evt: ACCOUNT_EVT.OnUpdateTransactions, value: {
        "account": account,
        "transactions": transactions
            .map((tx) => Transaction.fromTransactionEntity(tx))
            .toList()
      });
      AccountCore().messenger.add(txMsg);
    }
  }

  Future<Transaction> getTransactionDetail(String txid) async {
    APIResponse res =
        await HTTPAgent().get(Endpoint.url + '/wallet/account/tx/$txid');
    if (res.success) {
      Transaction transaction = Transaction.fromJson(res.data);
      return transaction;
    } else {
      throw Exception(res.message);
    }
  }

  Future<List<TransactionEntity>> _getTransactions(Account account) async {
    APIResponse res = await HTTPAgent()
        .get(Endpoint.url + '/wallet/account/txs/${account.id}');

    if (res.success) {
      List data = res.data;
      List<TransactionEntity> txs = [];
      for (var d in data) {
        txs.add(TransactionEntity.fromJson(account.id, d));
      }

      await DBOperator().transactionDao.insertTransactions(txs);
    }
    return this._loadTransactions(account.id);
  }

  Future<List<TransactionEntity>> _loadTransactions(String id) async {
    List<TransactionEntity> transactions =
        await DBOperator().transactionDao.findAllTransactionsById(id);
    List<TransactionEntity> txNull = [];
    List<TransactionEntity> txReady = [];
    transactions.forEach((t) {
      t.timestamp == null ? txNull.add(t) : txReady.add(t);
    });
    txReady.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
    return (txNull + txReady);
  }

  Future<List<Transaction>> getTrasnctions(String id) async {
    List<TransactionEntity> txEntities = await this._loadTransactions(id);
    List<Transaction> txs =
        txEntities.map((e) => Transaction.fromTransactionEntity(e)).toList();
    return txs;
  }

  @override
  Future<String> getReceivingAddress() {
    throw UnimplementedError('Implement on decorator');
  }

  @override
  Future<Map> getChangingAddress() {
    throw UnimplementedError();
  }

  @override
  Future<List> publishTransaction(
      String blockchainId, Transaction transaction) {
    throw UnimplementedError('Implement on decorator');
  }

  Future updateTransaction(String accountId, Map payload) async {
    List<Account> accounts = AccountCore().accounts[this.shareAccountId] ?? [];
    TransactionEntity txEntity = TransactionEntity.fromJson(accountId, payload);

    Account account = accounts.firstWhere((c) => c.id == accountId);
    AccountMessage txMsg = AccountMessage(
      evt: ACCOUNT_EVT.OnUpdateTransaction,
      value: {
        "account": account,
        "transaction": Transaction.fromTransactionEntity(txEntity)
      },
    );
    AccountCore().messenger.add(txMsg);
    await DBOperator().transactionDao.insertTransaction(txEntity);
  }

  Future updateAccount(String accountId, Map payload) async {
    List<AccountEntity> acs = await DBOperator().accountDao.findAllAccounts();

    AccountEntity ac = acs.firstWhere((a) => a.id == accountId);

    AccountEntity updated = ac.copyWith(
      balance: '${payload['balance']}',
    );

    await DBOperator().accountDao.insertAccount(updated);

    this._pushResult();
  }
}
