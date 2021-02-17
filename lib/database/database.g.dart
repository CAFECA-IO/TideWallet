// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String name;

  final List<Migration> _migrations = [];

  Callback _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String> listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  UserDao _userDaoInstance;

  AccountDao _accountDaoInstance;

  CurrencyDao _currencyDaoInstance;

  TransactionDao _transactionDaoInstance;

  UtxoDao _utxoDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `User` (`user_id` TEXT, `keystore` TEXT, `password_hash` TEXT, `password_salt` TEXT, `backup_status` INTEGER NOT NULL, PRIMARY KEY (`user_id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Account` (`account_id` TEXT, `user_id` TEXT, `purpose` INTEGER, `account_index` INTEGER, `curve_type` INTEGER, PRIMARY KEY (`account_id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Currency` (`currency_id` TEXT, `name` TEXT, `coin_type` INTEGER, `description` TEXT, `symbol` TEXT, `decimals` INTEGER, `address` TEXT, `type` TEXT, `total_supply` TEXT, `contract` TEXT, PRIMARY KEY (`currency_id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Transaction` (`transaction_id` TEXT, `account_id` TEXT, `currency_id` TEXT, `tx_id` TEXT, `source_address` TEXT, `destinction_address` TEXT, `timestamp` INTEGER, `confirmation` INTEGER, `gas_price` TEXT, `gas_used` INTEGER, `nonce` INTEGER, `block` INTEGER, `locktime` INTEGER, `fee` TEXT NOT NULL, `note` TEXT, `status` INTEGER, PRIMARY KEY (`transaction_id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Utxo` (`utxo_id` TEXT, `currency_id` TEXT, `tx_id` TEXT, `vout` INTEGER, `type` TEXT, `amount` TEXT, `chain_index` INTEGER, `key_index` INTEGER, `script` TEXT, `timestamp` INTEGER, `locked` INTEGER, `sequence` INTEGER, PRIMARY KEY (`utxo_id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  UserDao get userDao {
    return _userDaoInstance ??= _$UserDao(database, changeListener);
  }

  @override
  AccountDao get accountDao {
    return _accountDaoInstance ??= _$AccountDao(database, changeListener);
  }

  @override
  CurrencyDao get currencyDao {
    return _currencyDaoInstance ??= _$CurrencyDao(database, changeListener);
  }

  @override
  TransactionDao get transactionDao {
    return _transactionDaoInstance ??=
        _$TransactionDao(database, changeListener);
  }

  @override
  UtxoDao get utxoDao {
    return _utxoDaoInstance ??= _$UtxoDao(database, changeListener);
  }
}

class _$UserDao extends UserDao {
  _$UserDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _userInsertionAdapter = InsertionAdapter(
            database,
            'User',
            (User item) => <String, dynamic>{
                  'user_id': item.userId,
                  'keystore': item.keystore,
                  'password_hash': item.passwordHash,
                  'password_salt': item.passwordSalt,
                  'backup_status': item.backupStatus ? 1 : 0
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<User> _userInsertionAdapter;

  @override
  Future<User> findUser() async {
    return _queryAdapter.query('SELECT * FROM User limit 1',
        mapper: (Map<String, dynamic> row) => User(
            row['user_id'] as String,
            row['keystore'] as String,
            row['password_hash'] as String,
            row['password_salt'] as String,
            (row['backup_status'] as int) != 0));
  }

  @override
  Future<void> insertUser(User user) async {
    await _userInsertionAdapter.insert(user, OnConflictStrategy.replace);
  }
}

class _$AccountDao extends AccountDao {
  _$AccountDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _accountInsertionAdapter = InsertionAdapter(
            database,
            'Account',
            (Account item) => <String, dynamic>{
                  'account_id': item.accountId,
                  'user_id': item.userId,
                  'purpose': item.purpose,
                  'account_index': item.accountIndex,
                  'curve_type':
                      item.curveType == null ? null : (item.curveType ? 1 : 0)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Account> _accountInsertionAdapter;

  @override
  Future<List<Account>> findAllAccounts() async {
    return _queryAdapter.queryList('SELECT * FROM Account',
        mapper: (Map<String, dynamic> row) => Account(
            accountId: row['account_id'] as String,
            userId: row['user_id'] as String,
            purpose: row['purpose'] as int,
            accountIndex: row['account_index'] as int,
            curveType: row['curve_type'] == null
                ? null
                : (row['curve_type'] as int) != 0));
  }

  @override
  Future<void> insertAccount(Account account) async {
    await _accountInsertionAdapter.insert(account, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertAccounts(List<Account> accounts) {
    return _accountInsertionAdapter.insertListAndReturnIds(
        accounts, OnConflictStrategy.abort);
  }
}

class _$CurrencyDao extends CurrencyDao {
  _$CurrencyDao(this.database, this.changeListener)
      : _currencyInsertionAdapter = InsertionAdapter(
            database,
            'Currency',
            (Currency item) => <String, dynamic>{
                  'currency_id': item.currencyId,
                  'name': item.name,
                  'coin_type': item.coinType,
                  'description': item.description,
                  'symbol': item.symbol,
                  'decimals': item.decimals,
                  'address': item.address,
                  'type': item.type,
                  'total_supply': item.totalSupply,
                  'contract': item.contract
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final InsertionAdapter<Currency> _currencyInsertionAdapter;

  @override
  Future<void> insertCurrency(Currency currency) async {
    await _currencyInsertionAdapter.insert(currency, OnConflictStrategy.abort);
  }

  @override
  Future<List<int>> insertCurrencies(List<Currency> currencies) {
    return _currencyInsertionAdapter.insertListAndReturnIds(
        currencies, OnConflictStrategy.abort);
  }
}

class _$TransactionDao extends TransactionDao {
  _$TransactionDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _transactionInsertionAdapter = InsertionAdapter(
            database,
            'Transaction',
            (Transaction item) => <String, dynamic>{
                  'transaction_id': item.transactionId,
                  'account_id': item.accountId,
                  'currency_id': item.currencyId,
                  'tx_id': item.txId,
                  'source_address': item.sourceAddress,
                  'destinction_address': item.destinctionAddress,
                  'timestamp': item.timestamp,
                  'confirmation': item.confirmation,
                  'gas_price': item.gasPrice,
                  'gas_used': item.gasUsed,
                  'nonce': item.nonce,
                  'block': item.block,
                  'locktime': item.locktime,
                  'fee': item.fee,
                  'note': item.note,
                  'status': item.status
                }),
        _transactionUpdateAdapter = UpdateAdapter(
            database,
            'Transaction',
            ['transaction_id'],
            (Transaction item) => <String, dynamic>{
                  'transaction_id': item.transactionId,
                  'account_id': item.accountId,
                  'currency_id': item.currencyId,
                  'tx_id': item.txId,
                  'source_address': item.sourceAddress,
                  'destinction_address': item.destinctionAddress,
                  'timestamp': item.timestamp,
                  'confirmation': item.confirmation,
                  'gas_price': item.gasPrice,
                  'gas_used': item.gasUsed,
                  'nonce': item.nonce,
                  'block': item.block,
                  'locktime': item.locktime,
                  'fee': item.fee,
                  'note': item.note,
                  'status': item.status
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Transaction> _transactionInsertionAdapter;

  final UpdateAdapter<Transaction> _transactionUpdateAdapter;

  @override
  Future<Transaction> findAllTransactionsByCurrencyId(String id) async {
    return _queryAdapter.query(
        'SELECT * FROM Transaction WHERE currency_id = ?',
        arguments: <dynamic>[id],
        mapper: (Map<String, dynamic> row) => Transaction(
            transactionId: row['transaction_id'] as String,
            accountId: row['account_id'] as String,
            currencyId: row['currency_id'] as String,
            txId: row['tx_id'] as String,
            confirmation: row['confirmation'] as int,
            sourceAddress: row['source_address'] as String,
            destinctionAddress: row['destinction_address'] as String,
            gasPrice: row['gas_price'] as String,
            gasUsed: row['gas_used'] as int,
            note: row['note'] as String,
            block: row['block'] as int,
            locktime: row['locktime'] as int,
            fee: row['fee'] as String,
            nonce: row['nonce'] as int,
            status: row['status'] as int,
            timestamp: row['timestamp'] as int));
  }

  @override
  Future<void> insertTransaction(Transaction tx) async {
    await _transactionInsertionAdapter.insert(tx, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertTransactions(List<Transaction> transactions) {
    return _transactionInsertionAdapter.insertListAndReturnIds(
        transactions, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateTransaction(Transaction tx) async {
    await _transactionUpdateAdapter.update(tx, OnConflictStrategy.abort);
  }
}

class _$UtxoDao extends UtxoDao {
  _$UtxoDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _utxoInsertionAdapter = InsertionAdapter(
            database,
            'Utxo',
            (Utxo item) => <String, dynamic>{
                  'utxo_id': item.utxoId,
                  'currency_id': item.currencyId,
                  'tx_id': item.txId,
                  'vout': item.vout,
                  'type': item.type,
                  'amount': item.amount,
                  'chain_index': item.chainIndex,
                  'key_index': item.keyIndex,
                  'script': item.script,
                  'timestamp': item.timestamp,
                  'locked': item.locked == null ? null : (item.locked ? 1 : 0),
                  'sequence': item.sequence
                }),
        _utxoUpdateAdapter = UpdateAdapter(
            database,
            'Utxo',
            ['utxo_id'],
            (Utxo item) => <String, dynamic>{
                  'utxo_id': item.utxoId,
                  'currency_id': item.currencyId,
                  'tx_id': item.txId,
                  'vout': item.vout,
                  'type': item.type,
                  'amount': item.amount,
                  'chain_index': item.chainIndex,
                  'key_index': item.keyIndex,
                  'script': item.script,
                  'timestamp': item.timestamp,
                  'locked': item.locked == null ? null : (item.locked ? 1 : 0),
                  'sequence': item.sequence
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Utxo> _utxoInsertionAdapter;

  final UpdateAdapter<Utxo> _utxoUpdateAdapter;

  @override
  Future<List<Utxo>> findAllUtxosByCurrencyId(String id) async {
    return _queryAdapter.queryList('SELECT * FROM Utxo WHERE currency_id = ?',
        arguments: <dynamic>[id],
        mapper: (Map<String, dynamic> row) => Utxo(
            row['utxo_id'] as String,
            row['currency_id'] as String,
            row['tx_id'] as String,
            row['vout'] as int,
            row['type'] as String,
            row['amount'] as String,
            row['chain_index'] as int,
            row['key_index'] as int,
            row['script'] as String,
            row['timestamp'] as int,
            row['locked'] == null ? null : (row['locked'] as int) != 0,
            row['sequence'] as int));
  }

  @override
  Future<Utxo> findUtxoById(String id) async {
    return _queryAdapter.query('SELECT * FROM Utxo WHERE utxo_id = ?',
        arguments: <dynamic>[id],
        mapper: (Map<String, dynamic> row) => Utxo(
            row['utxo_id'] as String,
            row['currency_id'] as String,
            row['tx_id'] as String,
            row['vout'] as int,
            row['type'] as String,
            row['amount'] as String,
            row['chain_index'] as int,
            row['key_index'] as int,
            row['script'] as String,
            row['timestamp'] as int,
            row['locked'] == null ? null : (row['locked'] as int) != 0,
            row['sequence'] as int));
  }

  @override
  Future<void> insertUtxo(Utxo utxo) async {
    await _utxoInsertionAdapter.insert(utxo, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertUtxos(List<Utxo> utxos) {
    return _utxoInsertionAdapter.insertListAndReturnIds(
        utxos, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateUtxo(Utxo utxo) async {
    await _utxoUpdateAdapter.update(utxo, OnConflictStrategy.abort);
  }
}
