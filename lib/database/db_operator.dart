import 'dao/account_dao.dart';
import 'dao/transaction_dao.dart';
import 'dao/user_dao.dart';
import 'dao/currency_dao.dart';
import 'dao/utxo_dao.dart';
import 'database.dart';
import 'dao/account_currency_dao.dart';
import 'dao/network_dao.dart';

class DBOperator {
  AppDatabase database;
  bool _isInit = false;
  static const DB_NAME = 'tidewallet.db';

  DBOperator._privateConstructor();

  UserDao get userDao => database.userDao;
  AccountDao get accountDao => database.accountDao;
  CurrencyDao get currencyDao => database.currencyDao;
  TransactionDao get transactionDao => database.transactionDao;
  NetworkDao get networkDao => database.networkDao;
  AccountCurrencyDao get accountCurrencyDao => database.accountCurrencyDao;
  UtxoDao get utxoDao => database.utxoDao;

  factory DBOperator() => instance;

  static final DBOperator instance = DBOperator._privateConstructor();

  init({bool inMemory = false}) async {
    if (_isInit) return;

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
    await this.database?.close();
  }
}
