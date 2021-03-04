// database.dart

// required package imports
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'dao/account_dao.dart';
import 'dao/currency_dao.dart';
import 'dao/network_dao.dart';
import 'dao/user_dao.dart';
import 'dao/transaction_dao.dart';
import 'dao/account_currency_dao.dart';
import 'dao/utxo_dao.dart';
import 'dao/exchange_rate_dao.dart';
import 'entity/currency.dart';
import 'entity/account.dart';
import 'entity/transaction.dart';
import 'entity/user.dart';
import 'entity/account_currency.dart';
import 'entity/network.dart';
import 'entity/utxo.dart';
import 'entity/exchage_rate.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [
  UserEntity,
  AccountEntity,
  CurrencyEntity,
  TransactionEntity,
  NetworkEntity,
  AccountCurrencyEntity,
  UtxoEntity,
  ExchangeRateEntity
], views: [
  JoinCurrency,
  JoinUtxo,
  CurrencyWithAccountId
])
abstract class AppDatabase extends FloorDatabase {
  UserDao get userDao;
  AccountDao get accountDao;
  CurrencyDao get currencyDao;
  TransactionDao get transactionDao;
  NetworkDao get networkDao;
  AccountCurrencyDao get accountCurrencyDao;
  UtxoDao get utxoDao;
  ExchangeRateDao get exchangeRateDao;
}
