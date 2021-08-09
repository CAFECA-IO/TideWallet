import 'package:floor/floor.dart';
import '../entity/user.dart';

@dao
abstract class UserDao {
  @Query('SELECT * FROM User limit 1')
  Future<UserEntity?> findUser();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertUser(UserEntity user);

  @update
  Future<void> updateUser(UserEntity user);

  @delete
  Future<int> deleteUser(UserEntity user);
}
