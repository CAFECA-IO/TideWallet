import 'package:floor/floor.dart';

import '../entity/account.dart';

@dao
abstract class AccountDao {
  @Query('SELECT * FROM Account')
  Future<List<AccountEntity>> findAllAccounts();

  @Query('SELECT * FROM Account WHERE id = :id')
  Future<AccountEntity?> findAccount(String id);

  @Query('SELECT * FROM JoinAccount')
  Future<List<JoinAccount>> findAllJoinedAccount();

  @Query('SELECT * FROM JoinAccount WHERE JoinAccount.share_account_id = :id')
  Future<List<JoinAccount>> findJoinedAccountsByShareAccountId(String id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAccount(AccountEntity account);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertAccounts(List<AccountEntity> accounts);
}
