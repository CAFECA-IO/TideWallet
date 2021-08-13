import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:tidewallet3/helpers/logger.dart';

import '../constants/endpoint.dart';
import '../constants/account_config.dart';
import '../cores/account.dart';
import '../database/db_operator.dart';
import '../database/entity/account.dart';
import '../database/entity/currency.dart';
import '../database/entity/transaction.dart';
import '../helpers/http_agent.dart';
import '../models/account.model.dart';
import '../models/api_response.mode.dart';
import '../models/transaction.model.dart';
import 'account_service.dart';

class AccountServiceBase extends AccountService {
  late ACCOUNT _base;
  late String _shareAccountId;
  late int _syncInterval;
  late int? _lastSyncTimestamp = 0;

  get base => this._base;
  get lastSyncTimestamp => this._lastSyncTimestamp!;
  get shareAccountId => this._shareAccountId;

  AccountServiceBase();

  @override
  void init(String id, ACCOUNT base, {int? interval}) {
    this._shareAccountId = id;
    this._base = base;
    this._syncInterval = interval ?? this.syncInterval;
  }

  @override
  Future start() async {
    AccountEntity select =
        (await DBOperator().accountDao.findAccount(this._shareAccountId))!;
    await this._pushResult();
    this._lastSyncTimestamp = select.lastSyncTime;
  }

  @override
  void stop() {
    this.timer.cancel();
  }

  @override
  Future<Map<TransactionPriority, Decimal>> getTransactionFee(
      String blockchainId) async {
    throw UnimplementedError('Implement on decorator');
  }

  Future<List<AccountEntity>> getData() async {
    List<AccountEntity> accounts = [];
    AccountEntity accountEntity =
        (await DBOperator().accountDao.findAccount(this._shareAccountId))!;
    APIResponse res = await HTTPAgent()
        .get(Endpoint.url + '/wallet/account/${this._shareAccountId}');
    final acc = res.data;

    if (acc != null) {
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
        AccountEntity _tokenAccount = AccountEntity.fromAccountJson(
            token, this._shareAccountId, accountEntity.userId);
        accounts.add(_tokenAccount);
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

      return accounts;
    }

    return accounts;
  }

  synchro({bool? force}) async {
    int now = DateTime.now().millisecondsSinceEpoch;

    if (this._lastSyncTimestamp == null ||
        now - this._lastSyncTimestamp! > this._syncInterval ||
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
        .findJoinedAccountsByShareAccountId(this._shareAccountId);
    if (jaccs.isEmpty) return;

    List<Account> accs = [];

    for (JoinAccount jacc in jaccs) {
      accs.add(Account.fromJoinAccount(jacc, jaccs[0], this._base));
    }

    AccountCore().accounts[this._shareAccountId] = accs;

    AccountMessage currMsg = AccountMessage(
        evt: ACCOUNT_EVT.OnUpdateAccount,
        value: AccountCore().accounts[this._shareAccountId]);

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

  Future<List<TransactionEntity>> _loadTransactions(String currencyId) async {
    List<TransactionEntity> transactions =
        await DBOperator().transactionDao.findAllTransactionsById(currencyId);

    List<TransactionEntity> _transactions1 = transactions
        .where((transaction) => transaction.timestamp == null)
        .toList();
    List<TransactionEntity> _transactions2 = transactions
        .where((transaction) => transaction.timestamp != null)
        .toList()
          ..sort((a, b) => b.timestamp!.compareTo(a.timestamp!));

    return (_transactions1 + _transactions2);
  }

  @override
  Future<List> getChangingAddress(String shareAccountId) {
    throw UnimplementedError('Implement on decorator');
  }

  @override
  Future<List> getReceivingAddress(String shareAccountId) {
    throw UnimplementedError('Implement on decorator');
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
