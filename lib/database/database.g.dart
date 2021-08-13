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

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

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
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
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
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  UserDao? _userDaoInstance;

  AccountDao? _accountDaoInstance;

  CurrencyDao? _currencyDaoInstance;

  TransactionDao? _transactionDaoInstance;

  NetworkDao? _networkDaoInstance;

  UtxoDao? _utxoDaoInstance;

  ExchangeRateDao? _exchangeRateDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
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
            'CREATE TABLE IF NOT EXISTS `User` (`user_id` TEXT NOT NULL, `keystore` TEXT NOT NULL, `third_party_id` TEXT NOT NULL, `install_id` TEXT NOT NULL, `timestamp` INTEGER NOT NULL, `last_sync_time` INTEGER NOT NULL, PRIMARY KEY (`user_id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Account` (`id` TEXT NOT NULL, `share_account_id` TEXT NOT NULL, `user_id` TEXT NOT NULL, `blockchain_id` TEXT NOT NULL, `currency_id` TEXT NOT NULL, `purpose` INTEGER NOT NULL, `account_coin_type` INTEGER NOT NULL, `account_index` INTEGER NOT NULL, `curve_type` INTEGER NOT NULL, `balance` TEXT NOT NULL, `number_of_used_external_key` INTEGER, `number_of_used_internal_key` INTEGER, `last_sync_time` INTEGER, FOREIGN KEY (`user_id`) REFERENCES `User` (`user_id`) ON UPDATE NO ACTION ON DELETE CASCADE, FOREIGN KEY (`blockchain_id`) REFERENCES `Network` (`blockchain_id`) ON UPDATE NO ACTION ON DELETE CASCADE, FOREIGN KEY (`currency_id`) REFERENCES `Currency` (`currency_id`) ON UPDATE NO ACTION ON DELETE CASCADE, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Currency` (`currency_id` TEXT NOT NULL, `blockchain_id` TEXT, `contract` TEXT, `name` TEXT NOT NULL, `symbol` TEXT NOT NULL, `type` TEXT NOT NULL, `publish` INTEGER NOT NULL, `decimals` INTEGER NOT NULL, `exchange_rate` TEXT NOT NULL, `total_supply` TEXT, `image` TEXT, PRIMARY KEY (`currency_id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `_Transaction` (`transaction_id` TEXT NOT NULL, `account_id` TEXT NOT NULL, `tx_id` TEXT NOT NULL, `source_address` TEXT NOT NULL, `destinction_address` TEXT NOT NULL, `timestamp` INTEGER, `confirmation` INTEGER NOT NULL, `gas_price` TEXT, `gas_used` INTEGER, `fee` TEXT NOT NULL, `note` TEXT, `status` TEXT NOT NULL, `direction` TEXT NOT NULL, `amount` TEXT NOT NULL, PRIMARY KEY (`transaction_id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Network` (`blockchain_id` TEXT NOT NULL, `network` TEXT NOT NULL, `blockchain_coin_type` INTEGER NOT NULL, `publish` INTEGER NOT NULL, `chain_id` INTEGER NOT NULL, PRIMARY KEY (`blockchain_id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Utxo` (`utxo_id` TEXT NOT NULL, `account_id` TEXT NOT NULL, `tx_id` TEXT NOT NULL, `vout` INTEGER NOT NULL, `type` TEXT NOT NULL, `amount` TEXT NOT NULL, `chain_index` INTEGER NOT NULL, `key_index` INTEGER NOT NULL, `script` TEXT NOT NULL, `timestamp` INTEGER NOT NULL, `locked` INTEGER NOT NULL, `sequence` INTEGER NOT NULL, `address` TEXT NOT NULL, FOREIGN KEY (`account_id`) REFERENCES `Account` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, PRIMARY KEY (`utxo_id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ExchangeRate` (`exchange_rate_id` TEXT NOT NULL, `name` TEXT NOT NULL, `rate` TEXT NOT NULL, `lastSyncTime` INTEGER NOT NULL, `type` TEXT NOT NULL, PRIMARY KEY (`exchange_rate_id`))');

        await database.execute(
            '''CREATE VIEW IF NOT EXISTS `JoinAccount` AS SELECT * FROM Account INNER JOIN User ON Account.user_id = User.user_id INNER JOIN Network ON Account.blockchain_id = Network.blockchain_id INNER JOIN Currency ON Account.currency_id = Currency.currency_id''');
        await database.execute(
            '''CREATE VIEW IF NOT EXISTS `JoinUtxo` AS SELECT * FROM Utxo INNER JOIN AccountCurrency ON Utxo.accountcurrency_id = AccountCurrency.accountcurrency_id INNER JOIN Currency ON AccountCurrency.currency_id = Currency.currency_id''');

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
            (UserEntity item) => <String, Object?>{
                  'user_id': item.userId,
                  'keystore': item.keystore,
                  'third_party_id': item.thirdPartyId,
                  'install_id': item.installId,
                  'timestamp': item.timestamp,
                  'last_sync_time': item.lastSyncTime
                }),
        _userEntityUpdateAdapter = UpdateAdapter(
            database,
            'User',
            ['user_id'],
            (UserEntity item) => <String, Object?>{
                  'user_id': item.userId,
                  'keystore': item.keystore,
                  'third_party_id': item.thirdPartyId,
                  'install_id': item.installId,
                  'timestamp': item.timestamp,
                  'last_sync_time': item.lastSyncTime
                }),
        _userEntityDeletionAdapter = DeletionAdapter(
            database,
            'User',
            ['user_id'],
            (UserEntity item) => <String, Object?>{
                  'user_id': item.userId,
                  'keystore': item.keystore,
                  'third_party_id': item.thirdPartyId,
                  'install_id': item.installId,
                  'timestamp': item.timestamp,
                  'last_sync_time': item.lastSyncTime
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<UserEntity> _userEntityInsertionAdapter;

  final UpdateAdapter<UserEntity> _userEntityUpdateAdapter;

  final DeletionAdapter<UserEntity> _userEntityDeletionAdapter;

  @override
  Future<UserEntity?> findUser() async {
    return _queryAdapter.query('SELECT * FROM User limit 1',
        mapper: (Map<String, Object?> row) => UserEntity(
            row['user_id'] as String,
            row['keystore'] as String,
            row['third_party_id'] as String,
            row['install_id'] as String,
            row['timestamp'] as int,
            row['last_sync_time'] as int));
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
            (AccountEntity item) => <String, Object?>{
                  'id': item.id,
                  'share_account_id': item.shareAccountId,
                  'user_id': item.userId,
                  'blockchain_id': item.blockchainId,
                  'currency_id': item.currencyId,
                  'purpose': item.purpose,
                  'account_coin_type': item.accountCoinType,
                  'account_index': item.accountIndex,
                  'curve_type': item.curveType,
                  'balance': item.balance,
                  'number_of_used_external_key': item.numberOfUsedExternalKey,
                  'number_of_used_internal_key': item.numberOfUsedInternalKey,
                  'last_sync_time': item.lastSyncTime
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<AccountEntity> _accountEntityInsertionAdapter;

  @override
  Future<List<AccountEntity>> findAllAccounts() async {
    return _queryAdapter.queryList('SELECT * FROM Account',
        mapper: (Map<String, Object?> row) => AccountEntity(
            id: row['id'] as String,
            shareAccountId: row['share_account_id'] as String,
            userId: row['user_id'] as String,
            blockchainId: row['blockchain_id'] as String,
            currencyId: row['currency_id'] as String,
            purpose: row['purpose'] as int,
            accountCoinType: row['account_coin_type'] as int,
            accountIndex: row['account_index'] as int,
            curveType: row['curve_type'] as int,
            balance: row['balance'] as String,
            numberOfUsedExternalKey: row['number_of_used_external_key'] as int?,
            numberOfUsedInternalKey: row['number_of_used_internal_key'] as int?,
            lastSyncTime: row['last_sync_time'] as int?));
  }

  @override
  Future<AccountEntity?> findAccount(String id) async {
    return _queryAdapter.query(
        'SELECT * FROM Account WHERE account_id = ?1 LIMIT 1',
        mapper: (Map<String, Object?> row) => AccountEntity(
            id: row['id'] as String,
            shareAccountId: row['share_account_id'] as String,
            userId: row['user_id'] as String,
            blockchainId: row['blockchain_id'] as String,
            currencyId: row['currency_id'] as String,
            purpose: row['purpose'] as int,
            accountCoinType: row['account_coin_type'] as int,
            accountIndex: row['account_index'] as int,
            curveType: row['curve_type'] as int,
            balance: row['balance'] as String,
            numberOfUsedExternalKey: row['number_of_used_external_key'] as int?,
            numberOfUsedInternalKey: row['number_of_used_internal_key'] as int?,
            lastSyncTime: row['last_sync_time'] as int?),
        arguments: [id]);
  }

  @override
  Future<List<JoinAccount>> findAllJoinedAccount() async {
    return _queryAdapter.queryList('SELECT * FROM JoinAccount',
        mapper: (Map<String, Object?> row) => JoinAccount(
            id: row['id'] as String,
            shareAccountId: row['share_account_id'] as String,
            userId: row['user_id'] as String,
            blockchainId: row['blockchain_id'] as String,
            currencyId: row['currency_id'] as String,
            purpose: row['purpose'] as int,
            accountCoinType: row['account_coin_type'] as int,
            accountIndex: row['account_index'] as int,
            curveType: row['curve_type'] as int,
            balance: row['balance'] as String,
            numberOfUsedExternalKey: row['number_of_used_external_key'] as int,
            numberOfUsedInternalKey: row['number_of_used_internal_key'] as int,
            lastSyncTime: row['last_sync_time'] as int,
            keystore: row['keystore'] as String,
            thirdPartyId: row['third_party_id'] as String,
            installId: row['install_id'] as String,
            timestamp: row['timestamp'] as int,
            network: row['network'] as String,
            blockchainCoinType: row['blockchain_coin_type'] as int,
            chainId: row['chain_id'] as int,
            name: row['name'] as String,
            symbol: row['symbol'] as String,
            type: row['type'] as String,
            publish: (row['publish'] as int) != 0,
            contract: row['contract'] as String?,
            decimals: row['decimals'] as int,
            exchangeRate: row['exchange_rate'] as String,
            image: row['image'] as String));
  }

  @override
  Future<List<JoinAccount>> findJoinedAccountsByShareAccountId(
      String id) async {
    return _queryAdapter.queryList(
        'SELECT * FROM JoinAccount WHERE JoinAccount.share_account_id = ?1',
        mapper: (Map<String, Object?> row) => JoinAccount(
            id: row['id'] as String,
            shareAccountId: row['share_account_id'] as String,
            userId: row['user_id'] as String,
            blockchainId: row['blockchain_id'] as String,
            currencyId: row['currency_id'] as String,
            purpose: row['purpose'] as int,
            accountCoinType: row['account_coin_type'] as int,
            accountIndex: row['account_index'] as int,
            curveType: row['curve_type'] as int,
            balance: row['balance'] as String,
            numberOfUsedExternalKey: row['number_of_used_external_key'] as int,
            numberOfUsedInternalKey: row['number_of_used_internal_key'] as int,
            lastSyncTime: row['last_sync_time'] as int,
            keystore: row['keystore'] as String,
            thirdPartyId: row['third_party_id'] as String,
            installId: row['install_id'] as String,
            timestamp: row['timestamp'] as int,
            network: row['network'] as String,
            blockchainCoinType: row['blockchain_coin_type'] as int,
            chainId: row['chain_id'] as int,
            name: row['name'] as String,
            symbol: row['symbol'] as String,
            type: row['type'] as String,
            publish: (row['publish'] as int) != 0,
            contract: row['contract'] as String?,
            decimals: row['decimals'] as int,
            exchangeRate: row['exchange_rate'] as String,
            image: row['image'] as String),
        arguments: [id]);
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
            (CurrencyEntity item) => <String, Object?>{
                  'currency_id': item.currencyId,
                  'blockchain_id': item.blockchainId,
                  'contract': item.contract,
                  'name': item.name,
                  'symbol': item.symbol,
                  'type': item.type,
                  'publish': item.publish ? 1 : 0,
                  'decimals': item.decimals,
                  'exchange_rate': item.exchangeRate,
                  'total_supply': item.totalSupply,
                  'image': item.image
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<CurrencyEntity> _currencyEntityInsertionAdapter;

  @override
  Future<List<CurrencyEntity>> findAllCurrencies() async {
    return _queryAdapter.queryList('SELECT * FROM Currency',
        mapper: (Map<String, Object?> row) => CurrencyEntity(
            currencyId: row['currency_id'] as String,
            name: row['name'] as String,
            symbol: row['symbol'] as String,
            publish: (row['publish'] as int) != 0,
            decimals: row['decimals'] as int,
            type: row['type'] as String,
            image: row['image'] as String?,
            exchangeRate: row['exchange_rate'] as String,
            contract: row['contract'] as String?,
            blockchainId: row['blockchain_id'] as String?,
            totalSupply: row['total_supply'] as String?));
  }

  @override
  Future<List<CurrencyEntity>> findAllTokensByBlockchainId(String id) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Currency where blockchain_id = ?1',
        mapper: (Map<String, Object?> row) => CurrencyEntity(
            currencyId: row['currency_id'] as String,
            name: row['name'] as String,
            symbol: row['symbol'] as String,
            publish: (row['publish'] as int) != 0,
            decimals: row['decimals'] as int,
            type: row['type'] as String,
            image: row['image'] as String?,
            exchangeRate: row['exchange_rate'] as String,
            contract: row['contract'] as String?,
            blockchainId: row['blockchain_id'] as String?,
            totalSupply: row['total_supply'] as String?),
        arguments: [id]);
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
            (TransactionEntity item) => <String, Object?>{
                  'transaction_id': item.transactionId,
                  'account_id': item.accountId,
                  'tx_id': item.txId,
                  'source_address': item.sourceAddress,
                  'destinction_address': item.destinctionAddress,
                  'timestamp': item.timestamp,
                  'confirmation': item.confirmation,
                  'gas_price': item.gasPrice,
                  'gas_used': item.gasUsed,
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
            (TransactionEntity item) => <String, Object?>{
                  'transaction_id': item.transactionId,
                  'account_id': item.accountId,
                  'tx_id': item.txId,
                  'source_address': item.sourceAddress,
                  'destinction_address': item.destinctionAddress,
                  'timestamp': item.timestamp,
                  'confirmation': item.confirmation,
                  'gas_price': item.gasPrice,
                  'gas_used': item.gasUsed,
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
            (TransactionEntity item) => <String, Object?>{
                  'transaction_id': item.transactionId,
                  'account_id': item.accountId,
                  'tx_id': item.txId,
                  'source_address': item.sourceAddress,
                  'destinction_address': item.destinctionAddress,
                  'timestamp': item.timestamp,
                  'confirmation': item.confirmation,
                  'gas_price': item.gasPrice,
                  'gas_used': item.gasUsed,
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
        mapper: (Map<String, Object?> row) => TransactionEntity(
            transactionId: row['transaction_id'] as String,
            accountId: row['account_id'] as String,
            txId: row['tx_id'] as String,
            confirmation: row['confirmation'] as int,
            sourceAddress: row['source_address'] as String,
            destinctionAddress: row['destinction_address'] as String,
            gasPrice: row['gas_price'] as String?,
            gasUsed: row['gas_used'] as int?,
            note: row['note'] as String?,
            fee: row['fee'] as String,
            status: row['status'] as String,
            timestamp: row['timestamp'] as int?,
            direction: row['direction'] as String,
            amount: row['amount'] as String));
  }

  @override
  Future<List<TransactionEntity>> findAllTransactionsById(String id) async {
    return _queryAdapter.queryList(
        'SELECT * FROM _Transaction WHERE _Transaction.accountcurrency_id = ?1',
        mapper: (Map<String, Object?> row) => TransactionEntity(
            transactionId: row['transaction_id'] as String,
            accountId: row['account_id'] as String,
            txId: row['tx_id'] as String,
            confirmation: row['confirmation'] as int,
            sourceAddress: row['source_address'] as String,
            destinctionAddress: row['destinction_address'] as String,
            gasPrice: row['gas_price'] as String?,
            gasUsed: row['gas_used'] as int?,
            note: row['note'] as String?,
            fee: row['fee'] as String,
            status: row['status'] as String,
            timestamp: row['timestamp'] as int?,
            direction: row['direction'] as String,
            amount: row['amount'] as String),
        arguments: [id]);
  }

  @override
  Future<TransactionEntity?> findTransactionsByTxId(String id) async {
    return _queryAdapter.query(
        'SELECT * FROM _Transaction WHERE _Transaction.tx_id = ?1 limit 1',
        mapper: (Map<String, Object?> row) => TransactionEntity(
            transactionId: row['transaction_id'] as String,
            accountId: row['account_id'] as String,
            txId: row['tx_id'] as String,
            confirmation: row['confirmation'] as int,
            sourceAddress: row['source_address'] as String,
            destinctionAddress: row['destinction_address'] as String,
            gasPrice: row['gas_price'] as String?,
            gasUsed: row['gas_used'] as int?,
            note: row['note'] as String?,
            fee: row['fee'] as String,
            status: row['status'] as String,
            timestamp: row['timestamp'] as int?,
            direction: row['direction'] as String,
            amount: row['amount'] as String),
        arguments: [id]);
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
            (NetworkEntity item) => <String, Object?>{
                  'blockchain_id': item.blockchainId,
                  'network': item.network,
                  'blockchain_coin_type': item.blockchainCoinType,
                  'publish': item.publish ? 1 : 0,
                  'chain_id': item.chainId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<NetworkEntity> _networkEntityInsertionAdapter;

  @override
  Future<List<NetworkEntity>> findAllNetworks() async {
    return _queryAdapter.queryList('SELECT * FROM Network',
        mapper: (Map<String, Object?> row) => NetworkEntity(
            blockchainId: row['blockchain_id'] as String,
            network: row['network'] as String,
            blockchainCoinType: row['blockchain_coin_type'] as int,
            publish: (row['publish'] as int) != 0,
            chainId: row['chain_id'] as int));
  }

  @override
  Future<List<int>> insertNetworks(List<NetworkEntity> networks) {
    return _networkEntityInsertionAdapter.insertListAndReturnIds(
        networks, OnConflictStrategy.replace);
  }
}

class _$UtxoDao extends UtxoDao {
  _$UtxoDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _utxoEntityInsertionAdapter = InsertionAdapter(
            database,
            'Utxo',
            (UtxoEntity item) => <String, Object?>{
                  'utxo_id': item.utxoId,
                  'account_id': item.accountId,
                  'tx_id': item.txId,
                  'vout': item.vout,
                  'type': item.type,
                  'amount': item.amount,
                  'chain_index': item.changeIndex,
                  'key_index': item.keyIndex,
                  'script': item.script,
                  'timestamp': item.timestamp,
                  'locked': item.locked ? 1 : 0,
                  'sequence': item.sequence,
                  'address': item.address
                }),
        _utxoEntityUpdateAdapter = UpdateAdapter(
            database,
            'Utxo',
            ['utxo_id'],
            (UtxoEntity item) => <String, Object?>{
                  'utxo_id': item.utxoId,
                  'account_id': item.accountId,
                  'tx_id': item.txId,
                  'vout': item.vout,
                  'type': item.type,
                  'amount': item.amount,
                  'chain_index': item.changeIndex,
                  'key_index': item.keyIndex,
                  'script': item.script,
                  'timestamp': item.timestamp,
                  'locked': item.locked ? 1 : 0,
                  'sequence': item.sequence,
                  'address': item.address
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<UtxoEntity> _utxoEntityInsertionAdapter;

  final UpdateAdapter<UtxoEntity> _utxoEntityUpdateAdapter;

  @override
  Future<List<JoinUtxo>> findAllJoinedUtxosById(String id) async {
    return _queryAdapter.queryList(
        'SELECT * FROM JoinUtxo WHERE JoinUtxo.accountcurrency_id = ?1',
        mapper: (Map<String, Object?> row) => JoinUtxo(
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
            (row['locked'] as int) != 0,
            row['sequence'] as int,
            row['address'] as String,
            row['decimals'] as int),
        arguments: [id]);
  }

  @override
  Future<List<JoinUtxo>> findAllJoinedUtxos() async {
    return _queryAdapter.queryList('SELECT * FROM JoinUtxo',
        mapper: (Map<String, Object?> row) => JoinUtxo(
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
            (row['locked'] as int) != 0,
            row['sequence'] as int,
            row['address'] as String,
            row['decimals'] as int));
  }

  @override
  Future<List<UtxoEntity>> findAllUtxos() async {
    return _queryAdapter.queryList('SELECT * FROM Utxo',
        mapper: (Map<String, Object?> row) => UtxoEntity(
            row['utxo_id'] as String,
            row['account_id'] as String,
            row['tx_id'] as String,
            row['vout'] as int,
            row['type'] as String,
            row['amount'] as String,
            row['chain_index'] as int,
            row['key_index'] as int,
            row['script'] as String,
            row['timestamp'] as int,
            (row['locked'] as int) != 0,
            row['address'] as String,
            row['sequence'] as int));
  }

  @override
  Future<List<UtxoEntity>> findAllUtxosById(String id) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Utxo WHERE Utxo.accountcurrency_id = ?1',
        mapper: (Map<String, Object?> row) => UtxoEntity(
            row['utxo_id'] as String,
            row['account_id'] as String,
            row['tx_id'] as String,
            row['vout'] as int,
            row['type'] as String,
            row['amount'] as String,
            row['chain_index'] as int,
            row['key_index'] as int,
            row['script'] as String,
            row['timestamp'] as int,
            (row['locked'] as int) != 0,
            row['address'] as String,
            row['sequence'] as int),
        arguments: [id]);
  }

  @override
  Future<JoinUtxo?> findJoinedUtxoById(String id) async {
    return _queryAdapter.query(
        'SELECT * FROM JoinUtxo WHERE JoinUtxo.utxo_id = ?1 limit 1',
        mapper: (Map<String, Object?> row) => JoinUtxo(
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
            (row['locked'] as int) != 0,
            row['sequence'] as int,
            row['address'] as String,
            row['decimals'] as int),
        arguments: [id]);
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
            (ExchangeRateEntity item) => <String, Object?>{
                  'exchange_rate_id': item.exchangeRateId,
                  'name': item.name,
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
        mapper: (Map<String, Object?> row) => ExchangeRateEntity(
            exchangeRateId: row['exchange_rate_id'] as String,
            name: row['name'] as String,
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
