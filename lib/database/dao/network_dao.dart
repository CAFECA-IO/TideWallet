import 'package:floor/floor.dart';

import '../entity/network.dart';

@dao
abstract class NetworkDao {
  @Query('SELECT * FROM Network')
  Future<List<NetworkEntity>> findAllNetworks();

  @insert
  Future<List<int>> insertCurrencies(List<NetworkEntity> currencies);
}
