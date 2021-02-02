import 'dao/user_dao.dart';
import 'database.dart';

class DBOperator {
  AppDatabase database;
  bool _isInit = false;

  DBOperator._privateConstructor();

  UserDao get userDao => database.userDao;

  factory DBOperator() => instance;

  static final DBOperator instance = DBOperator._privateConstructor();

  init() async {
    if (_isInit) return;

    final db = await $FloorAppDatabase.databaseBuilder('tidewallet.db').build();
    this.database = db;
    this._isInit = true;
  }
}
