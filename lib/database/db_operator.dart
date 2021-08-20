import 'package:tidewallet3/helpers/logger.dart';

import 'dao/account_dao.dart';
import 'dao/transaction_dao.dart';
import 'dao/user_dao.dart';
import 'dao/currency_dao.dart';
import 'dao/utxo_dao.dart';
import 'database.dart';
import 'dao/network_dao.dart';
import 'dao/exchange_rate_dao.dart';

class DBOperator {
  AppDatabase? _database;
  bool _isInit = false;
  static const DB_NAME = 'tidewallet.db';
  factory DBOperator() => instance;

  static final DBOperator instance = DBOperator._privateConstructor();

  DBOperator._privateConstructor();

  set database(AppDatabase database) => this._database = database;
  AppDatabase get database => this._database!;

  UserDao get userDao => database.userDao;
  AccountDao get accountDao => database.accountDao;
  CurrencyDao get currencyDao => database.currencyDao;
  TransactionDao get transactionDao => database.transactionDao;
  NetworkDao get networkDao => database.networkDao;
  UtxoDao get utxoDao => database.utxoDao;
  ExchangeRateDao get exchangeRateDao => database.exchangeRateDao;

  init({bool inMemory = false}) async {
    Log.debug("DBOperator isInit: ${this._isInit}");
    if (_isInit) return;
    Log.debug("DBOperator isInit: ${this._isInit}");

    AppDatabase db;
    if (inMemory) {
      db = await $FloorAppDatabase.inMemoryDatabaseBuilder().build();
    } else {
      db = await $FloorAppDatabase.databaseBuilder(DB_NAME).build();
    }

    this.database = db;
    this._isInit = true;
  }

  down() async {
    await this.database.close();
  }
}
