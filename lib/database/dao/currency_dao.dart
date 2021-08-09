import 'package:floor/floor.dart';

import '../entity/currency.dart';

@dao
abstract class CurrencyDao {
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertCurrency(CurrencyEntity currency);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertCurrencies(List<CurrencyEntity> currencies);

  @Query('SELECT * FROM Currency')
  Future<List<CurrencyEntity>> findAllCurrencies();

  @Query('SELECT * FROM CurrencyWithAccountId where account_id = :id')
  Future<List<CurrencyWithAccountId>> findAllCurrenciesByAccountId(String id);
}
