import 'package:floor/floor.dart';

import '../entity/network.dart';

@dao
abstract class NetworkDao {
  @Query('SELECT * FROM Network')
  Future<List<Network>> findAllNetworks();

  @insert
  Future<List<int>> insertCurrencies(List<Network> currencies);
}
