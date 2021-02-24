import 'package:floor/floor.dart';

import '../entity/transaction.dart';

@dao
abstract class TransactionDao {
  @Query('SELECT * FROM _Transaction')
  Future<List<TransactionEntity>> findAllTransactions();

  @Query('SELECT * FROM _Transaction WHERE Transaction.currency_id = :id')
  Future<List<TransactionEntity>> findAllTransactionsByCurrencyId(String id);

  @Query('SELECT * FROM _Transaction WHERE Transaction.tx_id = :id limit 1')
  Future<TransactionEntity> findTransactionsByTxId(String id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertTransaction(TransactionEntity tx);

  @update
  Future<void> updateTransaction(TransactionEntity tx);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertTransactions(List<TransactionEntity> transactions);
}
