import 'package:floor/floor.dart';

import '../entity/transaction.dart';

@dao
abstract class TransactionDao {
  @Query('SELECT * FROM Transaction WHERE Transaction.currency_id = :id')
  Future<List<TransactionEntity>> findAllTransactionsByCurrencyId(String id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertTransaction(TransactionEntity tx);

  @update
  Future<void> updateTransaction(TransactionEntity tx);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertTransactions(List<TransactionEntity> transactions);
}
