import 'package:floor/floor.dart';
import '../entity/user.dart';

@dao
abstract class UserDao {
  @Query('SELECT * FROM User limit 1')
  Future<User> findUser();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertUser(User user);
}
