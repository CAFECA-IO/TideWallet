import 'package:floor/floor.dart';

import '../entity/account_currency.dart';

@dao
abstract class AccountCurrencyDao {
  @Query('SELECT * FROM AccountCurrency')
  Future<List<AccountCurrency>> findAllAccounts();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAccount(AccountCurrency account);

  @insert
  Future<List<int>> insertAccounts(List<AccountCurrency> accounts);
}