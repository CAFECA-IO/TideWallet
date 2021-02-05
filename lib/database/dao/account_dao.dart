import 'package:floor/floor.dart';

import '../entity/account.dart';

@dao
abstract class AccountDao {
  @Query('SELECT * FROM Account')
  Future<List<Account>> findAllAccounts();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAccount(Account account);

  @insert
  Future<List<int>> insertAccounts(List<Account> accounts);
}