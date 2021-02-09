import 'package:floor/floor.dart';

import '../entity/account_currency.dart';

@dao
abstract class AccountCurrencyDao {
  @Query('SELECT * FROM AccountCurrency')
  Future<List<AccountCurrencyEntity>> findAllCurrencies();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAccount(AccountCurrencyEntity account);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertCurrencies(List<AccountCurrencyEntity> currencies);


  @Query('SELECT * FROM JoinCurrency WHERE JoinCurrency.account_id = :id')
  Future<List<JoinCurrency>> findByAccountyId(String id);
}