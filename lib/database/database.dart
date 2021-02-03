// database.dart

// required package imports
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'dao/account_dao.dart';
import 'dao/currency_dao.dart';
import 'dao/user_dao.dart';
import 'dao/transaction_dao.dart';
import 'entity/currency.dart';
import 'entity/account.dart';
import 'entity/transaction.dart';
import 'entity/user.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [User, Account, Currency, Transaction])
abstract class AppDatabase extends FloorDatabase {
  UserDao get userDao;
  AccountDao get accountDao;
  CurrencyDao get currencyDao;
  TransactionDao get transactionDao;
}
