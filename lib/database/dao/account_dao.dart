import 'package:floor/floor.dart';

import '../entity/account.dart';

@dao
abstract class AccountDao {
  @Query('SELECT * FROM Account')
  Future<List<AccountEntity>> findAllAccounts();

  @Query('SELECT * FROM Account WHERE account_id = :id LIMIT 1')
  Future<AccountEntity?> findAccount(String id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAccount(AccountEntity account);

  @insert
  Future<List<int>> insertAccounts(List<AccountEntity> accounts);
}
