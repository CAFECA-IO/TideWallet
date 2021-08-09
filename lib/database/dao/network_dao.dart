import 'package:floor/floor.dart';

import '../entity/network.dart';

@dao
abstract class NetworkDao {
  @Query('SELECT * FROM Network')
  Future<List<NetworkEntity>?> findAllNetworks();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertNetworks(List<NetworkEntity> networks);
}
