import 'package:floor/floor.dart';

import '../entity/transaction.dart';

@dao
abstract class TransactionDao {
  @Query('SELECT * FROM Transaction WHERE currency_id = :id')
  Future<Transaction> findAllTransactionsByCurrencyId(String id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertTransaction(Transaction tx);

  @update
  Future<void> updateTransaction(Transaction tx);

  @insert
  Future<List<int>> insertTransactions(List<Transaction> transactions);
}