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

  NetworkDao _networkDaoInstance;

  AccountCurrencyDao _accountCurrencyDaoInstance;

  UtxoDao _utxoDaoInstance;

  ExchangeRateDao _exchangeRateDaoInstance;

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
            'CREATE TABLE IF NOT EXISTS `Account` (`account_id` TEXT, `user_id` TEXT, `network_id` TEXT, `account_index` INTEGER, FOREIGN KEY (`user_id`) REFERENCES `User` (`user_id`) ON UPDATE NO ACTION ON DELETE CASCADE, PRIMARY KEY (`account_id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Currency` (`currency_id` TEXT, `name` TEXT, `description` TEXT, `symbol` TEXT, `decimals` INTEGER, `address` TEXT, `type` TEXT, `total_supply` TEXT, `contract` TEXT, `image` TEXT, PRIMARY KEY (`currency_id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `_Transaction` (`transaction_id` TEXT, `accountcurrency_id` TEXT, `tx_id` TEXT, `source_address` TEXT, `destinction_address` TEXT, `timestamp` INTEGER, `confirmation` INTEGER, `gas_price` TEXT, `gas_used` INTEGER, `block` INTEGER, `fee` TEXT NOT NULL, `note` TEXT, `status` TEXT, `direction` TEXT, `amount` TEXT, PRIMARY KEY (`transaction_id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Network` (`network_id` TEXT, `network` TEXT NOT NULL, `coin_type` INTEGER, `publish` INTEGER, `chain_id` INTEGER, PRIMARY KEY (`network_id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `AccountCurrency` (`accountcurrency_id` TEXT NOT NULL, `account_id` TEXT, `currency_id` TEXT, `balance` TEXT, `number_of_used_external_key` INTEGER, `number_of_used_internal_key` INTEGER, `last_sync_time` INTEGER, FOREIGN KEY (`account_id`) REFERENCES `Account` (`account_id`) ON UPDATE NO ACTION ON DELETE CASCADE, FOREIGN KEY (`currency_id`) REFERENCES `Currency` (`currency_id`) ON UPDATE NO ACTION ON DELETE CASCADE, PRIMARY KEY (`accountcurrency_id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Utxo` (`utxo_id` TEXT NOT NULL, `accountcurrency_id` TEXT, `tx_id` TEXT, `vout` INTEGER, `type` TEXT, `amount` TEXT, `chain_index` INTEGER, `key_index` INTEGER, `script` TEXT, `timestamp` INTEGER, `locked` INTEGER, `sequence` INTEGER, `address` TEXT, FOREIGN KEY (`accountcurrency_id`) REFERENCES `AccountCurrency` (`accountcurrency_id`) ON UPDATE NO ACTION ON DELETE CASCADE, PRIMARY KEY (`utxo_id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ExchangeRate` (`exchange_rate_id` TEXT, `rate` TEXT, `lastSyncTime` INTEGER, `type` TEXT, PRIMARY KEY (`exchange_rate_id`))');

        await database.execute(
            '''CREATE VIEW IF NOT EXISTS `JoinCurrency` AS SELECT * FROM AccountCurrency INNER JOIN Currency ON AccountCurrency.currency_id = Currency.currency_id INNER JOIN Account ON AccountCurrency.account_id = Account.account_id INNER JOIN Network ON Account.network_id = Network.network_id''');
        await database.execute(
            '''CREATE VIEW IF NOT EXISTS `JoinUtxo` AS SELECT * FROM Utxo INNER JOIN AccountCurrency ON Utxo.accountcurrency_id = AccountCurrency.accountcurrency_id INNER JOIN Currency ON AccountCurrency.currency_id = Currency.currency_id''');
        await database.execute(
            '''CREATE VIEW IF NOT EXISTS `CurrencyWithAccountId` AS SELECT * FROM Currency INNER JOIN AccountCurrency ON Currency.currency_id = AccountCurrency.currency_id''');

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
  NetworkDao get networkDao {
    return _networkDaoInstance ??= _$NetworkDao(database, changeListener);
  }

  @override
  AccountCurrencyDao get accountCurrencyDao {
    return _accountCurrencyDaoInstance ??=
        _$AccountCurrencyDao(database, changeListener);
  }

  @override
  UtxoDao get utxoDao {
    return _utxoDaoInstance ??= _$UtxoDao(database, changeListener);
  }

  @override
  ExchangeRateDao get exchangeRateDao {
    return _exchangeRateDaoInstance ??=
        _$ExchangeRateDao(database, changeListener);
  }
}

class _$UserDao extends UserDao {
  _$UserDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _userEntityInsertionAdapter = InsertionAdapter(
            database,
            'User',
            (UserEntity item) => <String, dynamic>{
                  'user_id': item.userId,
                  'keystore': item.keystore,
                  'password_hash': item.passwordHash,
                  'password_salt': item.passwordSalt,
                  'backup_status': item.backupStatus ? 1 : 0
                }),
        _userEntityUpdateAdapter = UpdateAdapter(
            database,
            'User',
            ['user_id'],
            (UserEntity item) => <String, dynamic>{
                  'user_id': item.userId,
                  'keystore': item.keystore,
                  'password_hash': item.passwordHash,
                  'password_salt': item.passwordSalt,
                  'backup_status': item.backupStatus ? 1 : 0
                }),
        _userEntityDeletionAdapter = DeletionAdapter(
            database,
            'User',
            ['user_id'],
            (UserEntity item) => <String, dynamic>{
                  'user_id': item.userId,
                  'keystore': item.keystore,
                  'password_hash': item.passwordHash,
                  'password_salt': item.passwordSalt,
                  'backup_status': item.backupStatus ? 1 : 0
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<UserEntity> _userEntityInsertionAdapter;

  final UpdateAdapter<UserEntity> _userEntityUpdateAdapter;

  final DeletionAdapter<UserEntity> _userEntityDeletionAdapter;

  @override
  Future<UserEntity> findUser() async {
    return _queryAdapter.query('SELECT * FROM User limit 1',
        mapper: (Map<String, dynamic> row) => UserEntity(
            row['user_id'] as String,
            row['keystore'] as String,
            row['password_hash'] as String,
            row['password_salt'] as String,
            (row['backup_status'] as int) != 0));
  }

  @override
  Future<void> insertUser(UserEntity user) async {
    await _userEntityInsertionAdapter.insert(user, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    await _userEntityUpdateAdapter.update(user, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteUser(UserEntity user) {
    return _userEntityDeletionAdapter.deleteAndReturnChangedRows(user);
  }
}

class _$AccountDao extends AccountDao {
  _$AccountDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _accountEntityInsertionAdapter = InsertionAdapter(
            database,
            'Account',
            (AccountEntity item) => <String, dynamic>{
                  'account_id': item.accountId,
                  'user_id': item.userId,
                  'network_id': item.networkId,
                  'account_index': item.accountIndex
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<AccountEntity> _accountEntityInsertionAdapter;

  @override
  Future<List<AccountEntity>> findAllAccounts() async {
    return _queryAdapter.queryList('SELECT * FROM Account',
        mapper: (Map<String, dynamic> row) => AccountEntity(
            accountId: row['account_id'] as String,
            userId: row['user_id'] as String,
            networkId: row['network_id'] as String,
            accountIndex: row['account_index'] as int));
  }

  @override
  Future<AccountEntity> findAccount(String id) async {
    return _queryAdapter.query(
        'SELECT * FROM Account WHERE account_id = ? LIMIT 1',
        arguments: <dynamic>[id],
        mapper: (Map<String, dynamic> row) => AccountEntity(
            accountId: row['account_id'] as String,
            userId: row['user_id'] as String,
            networkId: row['network_id'] as String,
            accountIndex: row['account_index'] as int));
  }

  @override
  Future<void> insertAccount(AccountEntity account) async {
    await _accountEntityInsertionAdapter.insert(
        account, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertAccounts(List<AccountEntity> accounts) {
    return _accountEntityInsertionAdapter.insertListAndReturnIds(
        accounts, OnConflictStrategy.abort);
  }
}

class _$CurrencyDao extends CurrencyDao {
  _$CurrencyDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _currencyEntityInsertionAdapter = InsertionAdapter(
            database,
            'Currency',
            (CurrencyEntity item) => <String, dynamic>{
                  'currency_id': item.currencyId,
                  'name': item.name,
                  'description': item.description,
                  'symbol': item.symbol,
                  'decimals': item.decimals,
                  'address': item.address,
                  'type': item.type,
                  'total_supply': item.totalSupply,
                  'contract': item.contract,
                  'image': item.image
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<CurrencyEntity> _currencyEntityInsertionAdapter;

  @override
  Future<List<CurrencyEntity>> findAllCurrencies() async {
    return _queryAdapter.queryList('SELECT * FROM Currency',
        mapper: (Map<String, dynamic> row) => CurrencyEntity(
            currencyId: row['currency_id'] as String,
            name: row['name'] as String,
            symbol: row['symbol'] as String,
            description: row['description'] as String,
            address: row['address'] as String,
            contract: row['contract'] as String,
            decimals: row['decimals'] as int,
            totalSupply: row['total_supply'] as String,
            type: row['type'] as String,
            image: row['image'] as String));
  }

  @override
  Future<List<CurrencyWithAccountId>> findAllCurrenciesByAccountId(
      String id) async {
    return _queryAdapter.queryList(
        'SELECT * FROM CurrencyWithAccountId where account_id = ?',
        arguments: <dynamic>[id],
        mapper: (Map<String, dynamic> row) => CurrencyWithAccountId(
            currencyId: row['currency_id'] as String,
            accountId: row['account_id'] as String,
            symbol: row['symbol'] as String));
  }

  @override
  Future<void> insertCurrency(CurrencyEntity currency) async {
    await _currencyEntityInsertionAdapter.insert(
        currency, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertCurrencies(List<CurrencyEntity> currencies) {
    return _currencyEntityInsertionAdapter.insertListAndReturnIds(
        currencies, OnConflictStrategy.replace);
  }
}

class _$TransactionDao extends TransactionDao {
  _$TransactionDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _transactionEntityInsertionAdapter = InsertionAdapter(
            database,
            '_Transaction',
            (TransactionEntity item) => <String, dynamic>{
                  'transaction_id': item.transactionId,
                  'accountcurrency_id': item.accountcurrencyId,
                  'tx_id': item.txId,
                  'source_address': item.sourceAddress,
                  'destinction_address': item.destinctionAddress,
                  'timestamp': item.timestamp,
                  'confirmation': item.confirmation,
                  'gas_price': item.gasPrice,
                  'gas_used': item.gasUsed,
                  'block': item.block,
                  'fee': item.fee,
                  'note': item.note,
                  'status': item.status,
                  'direction': item.direction,
                  'amount': item.amount
                }),
        _transactionEntityUpdateAdapter = UpdateAdapter(
            database,
            '_Transaction',
            ['transaction_id'],
            (TransactionEntity item) => <String, dynamic>{
                  'transaction_id': item.transactionId,
                  'accountcurrency_id': item.accountcurrencyId,
                  'tx_id': item.txId,
                  'source_address': item.sourceAddress,
                  'destinction_address': item.destinctionAddress,
                  'timestamp': item.timestamp,
                  'confirmation': item.confirmation,
                  'gas_price': item.gasPrice,
                  'gas_used': item.gasUsed,
                  'block': item.block,
                  'fee': item.fee,
                  'note': item.note,
                  'status': item.status,
                  'direction': item.direction,
                  'amount': item.amount
                }),
        _transactionEntityDeletionAdapter = DeletionAdapter(
            database,
            '_Transaction',
            ['transaction_id'],
            (TransactionEntity item) => <String, dynamic>{
                  'transaction_id': item.transactionId,
                  'accountcurrency_id': item.accountcurrencyId,
                  'tx_id': item.txId,
                  'source_address': item.sourceAddress,
                  'destinction_address': item.destinctionAddress,
                  'timestamp': item.timestamp,
                  'confirmation': item.confirmation,
                  'gas_price': item.gasPrice,
                  'gas_used': item.gasUsed,
                  'block': item.block,
                  'fee': item.fee,
                  'note': item.note,
                  'status': item.status,
                  'direction': item.direction,
                  'amount': item.amount
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<TransactionEntity> _transactionEntityInsertionAdapter;

  final UpdateAdapter<TransactionEntity> _transactionEntityUpdateAdapter;

  final DeletionAdapter<TransactionEntity> _transactionEntityDeletionAdapter;

  @override
  Future<List<TransactionEntity>> findAllTransactions() async {
    return _queryAdapter.queryList('SELECT * FROM _Transaction',
        mapper: (Map<String, dynamic> row) => TransactionEntity(
            transactionId: row['transaction_id'] as String,
            accountcurrencyId: row['accountcurrency_id'] as String,
            txId: row['tx_id'] as String,
            confirmation: row['confirmation'] as int,
            sourceAddress: row['source_address'] as String,
            destinctionAddress: row['destinction_address'] as String,
            gasPrice: row['gas_price'] as String,
            gasUsed: row['gas_used'] as int,
            note: row['note'] as String,
            block: row['block'] as int,
            fee: row['fee'] as String,
            status: row['status'] as String,
            timestamp: row['timestamp'] as int,
            direction: row['direction'] as String,
            amount: row['amount'] as String));
  }

  @override
  Future<List<TransactionEntity>> findAllTransactionsById(String id) async {
    return _queryAdapter.queryList(
        'SELECT * FROM _Transaction WHERE _Transaction.accountcurrency_id = ?',
        arguments: <dynamic>[id],
        mapper: (Map<String, dynamic> row) => TransactionEntity(
            transactionId: row['transaction_id'] as String,
            accountcurrencyId: row['accountcurrency_id'] as String,
            txId: row['tx_id'] as String,
            confirmation: row['confirmation'] as int,
            sourceAddress: row['source_address'] as String,
            destinctionAddress: row['destinction_address'] as String,
            gasPrice: row['gas_price'] as String,
            gasUsed: row['gas_used'] as int,
            note: row['note'] as String,
            block: row['block'] as int,
            fee: row['fee'] as String,
            status: row['status'] as String,
            timestamp: row['timestamp'] as int,
            direction: row['direction'] as String,
            amount: row['amount'] as String));
  }

  @override
  Future<TransactionEntity> findTransactionsByTxId(String id) async {
    return _queryAdapter.query(
        'SELECT * FROM _Transaction WHERE _Transaction.tx_id = ? limit 1',
        arguments: <dynamic>[id],
        mapper: (Map<String, dynamic> row) => TransactionEntity(
            transactionId: row['transaction_id'] as String,
            accountcurrencyId: row['accountcurrency_id'] as String,
            txId: row['tx_id'] as String,
            confirmation: row['confirmation'] as int,
            sourceAddress: row['source_address'] as String,
            destinctionAddress: row['destinction_address'] as String,
            gasPrice: row['gas_price'] as String,
            gasUsed: row['gas_used'] as int,
            note: row['note'] as String,
            block: row['block'] as int,
            fee: row['fee'] as String,
            status: row['status'] as String,
            timestamp: row['timestamp'] as int,
            direction: row['direction'] as String,
            amount: row['amount'] as String));
  }

  @override
  Future<void> insertTransaction(TransactionEntity tx) async {
    await _transactionEntityInsertionAdapter.insert(
        tx, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertTransactions(List<TransactionEntity> transactions) {
    return _transactionEntityInsertionAdapter.insertListAndReturnIds(
        transactions, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateTransaction(TransactionEntity tx) async {
    await _transactionEntityUpdateAdapter.update(tx, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteTransactions(List<TransactionEntity> txs) async {
    await _transactionEntityDeletionAdapter.deleteList(txs);
  }
}

class _$NetworkDao extends NetworkDao {
  _$NetworkDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _networkEntityInsertionAdapter = InsertionAdapter(
            database,
            'Network',
            (NetworkEntity item) => <String, dynamic>{
                  'network_id': item.networkId,
                  'network': item.network,
                  'coin_type': item.coinType,
                  'publish':
                      item.publish == null ? null : (item.publish ? 1 : 0),
                  'chain_id': item.chainId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<NetworkEntity> _networkEntityInsertionAdapter;

  @override
  Future<List<NetworkEntity>> findAllNetworks() async {
    return _queryAdapter.queryList('SELECT * FROM Network',
        mapper: (Map<String, dynamic> row) => NetworkEntity(
            networkId: row['network_id'] as String,
            network: row['network'] as String,
            coinType: row['coin_type'] as int,
            publish:
                row['publish'] == null ? null : (row['publish'] as int) != 0,
            chainId: row['chain_id'] as int));
  }

  @override
  Future<List<int>> insertNetworks(List<NetworkEntity> networks) {
    return _networkEntityInsertionAdapter.insertListAndReturnIds(
        networks, OnConflictStrategy.abort);
  }
}

class _$AccountCurrencyDao extends AccountCurrencyDao {
  _$AccountCurrencyDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _accountCurrencyEntityInsertionAdapter = InsertionAdapter(
            database,
            'AccountCurrency',
            (AccountCurrencyEntity item) => <String, dynamic>{
                  'accountcurrency_id': item.accountcurrencyId,
                  'account_id': item.accountId,
                  'currency_id': item.currencyId,
                  'balance': item.balance,
                  'number_of_used_external_key': item.numberOfUsedExternalKey,
                  'number_of_used_internal_key': item.numberOfUsedInternalKey,
                  'last_sync_time': item.lastSyncTime
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<AccountCurrencyEntity>
      _accountCurrencyEntityInsertionAdapter;

  @override
  Future<List<AccountCurrencyEntity>> findAllCurrencies() async {
    return _queryAdapter.queryList('SELECT * FROM AccountCurrency',
        mapper: (Map<String, dynamic> row) => AccountCurrencyEntity(
            accountcurrencyId: row['accountcurrency_id'] as String,
            accountId: row['account_id'] as String,
            currencyId: row['currency_id'] as String,
            balance: row['balance'] as String,
            numberOfUsedExternalKey: row['number_of_used_external_key'] as int,
            numberOfUsedInternalKey: row['number_of_used_internal_key'] as int,
            lastSyncTime: row['last_sync_time'] as int));
  }

  @override
  Future<AccountCurrencyEntity> findOneByAccountyId(String id) async {
    return _queryAdapter.query(
        'SELECT * FROM AccountCurrency WHERE AccountCurrency.account_id = ? LIMIT 1',
        arguments: <dynamic>[id],
        mapper: (Map<String, dynamic> row) => AccountCurrencyEntity(
            accountcurrencyId: row['accountcurrency_id'] as String,
            accountId: row['account_id'] as String,
            currencyId: row['currency_id'] as String,
            balance: row['balance'] as String,
            numberOfUsedExternalKey: row['number_of_used_external_key'] as int,
            numberOfUsedInternalKey: row['number_of_used_internal_key'] as int,
            lastSyncTime: row['last_sync_time'] as int));
  }

  @override
  Future<List<JoinCurrency>> findJoinedByAccountyId(String id) async {
    return _queryAdapter.queryList(
        'SELECT * FROM JoinCurrency WHERE JoinCurrency.account_id = ?',
        arguments: <dynamic>[id],
        mapper: (Map<String, dynamic> row) => JoinCurrency(
            accountcurrencyId: row['accountcurrency_id'] as String,
            currencyId: row['currency_id'] as String,
            symbol: row['symbol'] as String,
            name: row['name'] as String,
            balance: row['balance'] as String,
            accountIndex: row['account_index'] as int,
            coinType: row['coin_type'] as int,
            image: row['image'] as String,
            blockchainId: row['network_id'] as String,
            network: row['network'] as String,
            chainId: row['chain_id'] as int,
            publish:
                row['publish'] == null ? null : (row['publish'] as int) != 0,
            contract: row['contract'] as String,
            decimals: row['decimals'] as int,
            type: row['type'] as String,
            accountId: row['account_id'] as String));
  }

  @override
  Future<void> insertAccount(AccountCurrencyEntity account) async {
    await _accountCurrencyEntityInsertionAdapter.insert(
        account, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertCurrencies(List<AccountCurrencyEntity> currencies) {
    return _accountCurrencyEntityInsertionAdapter.insertListAndReturnIds(
        currencies, OnConflictStrategy.replace);
  }
}

class _$UtxoDao extends UtxoDao {
  _$UtxoDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _utxoEntityInsertionAdapter = InsertionAdapter(
            database,
            'Utxo',
            (UtxoEntity item) => <String, dynamic>{
                  'utxo_id': item.utxoId,
                  'accountcurrency_id': item.accountcurrencyId,
                  'tx_id': item.txId,
                  'vout': item.vout,
                  'type': item.type,
                  'amount': item.amount,
                  'chain_index': item.chainIndex,
                  'key_index': item.keyIndex,
                  'script': item.script,
                  'timestamp': item.timestamp,
                  'locked': item.locked == null ? null : (item.locked ? 1 : 0),
                  'sequence': item.sequence,
                  'address': item.address
                }),
        _utxoEntityUpdateAdapter = UpdateAdapter(
            database,
            'Utxo',
            ['utxo_id'],
            (UtxoEntity item) => <String, dynamic>{
                  'utxo_id': item.utxoId,
                  'accountcurrency_id': item.accountcurrencyId,
                  'tx_id': item.txId,
                  'vout': item.vout,
                  'type': item.type,
                  'amount': item.amount,
                  'chain_index': item.chainIndex,
                  'key_index': item.keyIndex,
                  'script': item.script,
                  'timestamp': item.timestamp,
                  'locked': item.locked == null ? null : (item.locked ? 1 : 0),
                  'sequence': item.sequence,
                  'address': item.address
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<UtxoEntity> _utxoEntityInsertionAdapter;

  final UpdateAdapter<UtxoEntity> _utxoEntityUpdateAdapter;

  @override
  Future<List<JoinUtxo>> findAllJoinedUtxosById(
      String accountcurrencyId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM JoinUtxo WHERE JoinUtxo.accountcurrency_id = ?',
        arguments: <dynamic>[accountcurrencyId],
        mapper: (Map<String, dynamic> row) => JoinUtxo(
            row['utxo_id'] as String,
            row['accountcurrency_id'] as String,
            row['tx_id'] as String,
            row['vout'] as int,
            row['type'] as String,
            row['amount'] as String,
            row['chain_index'] as int,
            row['key_index'] as int,
            row['script'] as String,
            row['timestamp'] as int,
            row['locked'] == null ? null : (row['locked'] as int) != 0,
            row['sequence'] as int,
            row['address'] as String,
            row['decimals'] as int));
  }

  @override
  Future<List<JoinUtxo>> findAllJoinedUtxos() async {
    return _queryAdapter.queryList('SELECT * FROM JoinUtxo',
        mapper: (Map<String, dynamic> row) => JoinUtxo(
            row['utxo_id'] as String,
            row['accountcurrency_id'] as String,
            row['tx_id'] as String,
            row['vout'] as int,
            row['type'] as String,
            row['amount'] as String,
            row['chain_index'] as int,
            row['key_index'] as int,
            row['script'] as String,
            row['timestamp'] as int,
            row['locked'] == null ? null : (row['locked'] as int) != 0,
            row['sequence'] as int,
            row['address'] as String,
            row['decimals'] as int));
  }

  @override
  Future<List<UtxoEntity>> findAllUtxos() async {
    return _queryAdapter.queryList('SELECT * FROM Utxo',
        mapper: (Map<String, dynamic> row) => UtxoEntity(
            row['utxo_id'] as String,
            row['accountcurrency_id'] as String,
            row['tx_id'] as String,
            row['vout'] as int,
            row['type'] as String,
            row['amount'] as String,
            row['chain_index'] as int,
            row['key_index'] as int,
            row['script'] as String,
            row['timestamp'] as int,
            row['locked'] == null ? null : (row['locked'] as int) != 0,
            row['address'] as String,
            row['sequence'] as int));
  }

  @override
  Future<List<UtxoEntity>> findAllUtxosById(String accountcurrencyId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Utxo WHERE Utxo.accountcurrency_id = ?',
        arguments: <dynamic>[accountcurrencyId],
        mapper: (Map<String, dynamic> row) => UtxoEntity(
            row['utxo_id'] as String,
            row['accountcurrency_id'] as String,
            row['tx_id'] as String,
            row['vout'] as int,
            row['type'] as String,
            row['amount'] as String,
            row['chain_index'] as int,
            row['key_index'] as int,
            row['script'] as String,
            row['timestamp'] as int,
            row['locked'] == null ? null : (row['locked'] as int) != 0,
            row['address'] as String,
            row['sequence'] as int));
  }

  @override
  Future<JoinUtxo> findJoinedUtxoById(String id) async {
    return _queryAdapter.query(
        'SELECT * FROM JoinUtxo WHERE JoinUtxo.utxo_id = ? limit 1',
        arguments: <dynamic>[id],
        mapper: (Map<String, dynamic> row) => JoinUtxo(
            row['utxo_id'] as String,
            row['accountcurrency_id'] as String,
            row['tx_id'] as String,
            row['vout'] as int,
            row['type'] as String,
            row['amount'] as String,
            row['chain_index'] as int,
            row['key_index'] as int,
            row['script'] as String,
            row['timestamp'] as int,
            row['locked'] == null ? null : (row['locked'] as int) != 0,
            row['sequence'] as int,
            row['address'] as String,
            row['decimals'] as int));
  }

  @override
  Future<void> insertUtxo(UtxoEntity utxo) async {
    await _utxoEntityInsertionAdapter.insert(utxo, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertUtxos(List<UtxoEntity> utxos) {
    return _utxoEntityInsertionAdapter.insertListAndReturnIds(
        utxos, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateUtxo(UtxoEntity utxo) async {
    await _utxoEntityUpdateAdapter.update(utxo, OnConflictStrategy.abort);
  }
}

class _$ExchangeRateDao extends ExchangeRateDao {
  _$ExchangeRateDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _exchangeRateEntityInsertionAdapter = InsertionAdapter(
            database,
            'ExchangeRate',
            (ExchangeRateEntity item) => <String, dynamic>{
                  'exchange_rate_id': item.exchangeRateId,
                  'rate': item.rate,
                  'lastSyncTime': item.lastSyncTime,
                  'type': item.type
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ExchangeRateEntity>
      _exchangeRateEntityInsertionAdapter;

  @override
  Future<List<ExchangeRateEntity>> findAllExchageRates() async {
    return _queryAdapter.queryList('SELECT * FROM ExchangeRate',
        mapper: (Map<String, dynamic> row) => ExchangeRateEntity(
            exchangeRateId: row['exchange_rate_id'] as String,
            rate: row['rate'] as String,
            lastSyncTime: row['lastSyncTime'] as int,
            type: row['type'] as String));
  }

  @override
  Future<List<int>> insertExchangeRates(List<ExchangeRateEntity> rates) {
    return _exchangeRateEntityInsertionAdapter.insertListAndReturnIds(
        rates, OnConflictStrategy.replace);
  }
}
