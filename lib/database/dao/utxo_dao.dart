import 'package:floor/floor.dart';

import '../entity/utxo.dart';

@dao
abstract class UtxoDao {
  @Query('SELECT * FROM Utxo WHERE currency_id = :id')
  Future<List<Utxo>> findAllUtxosByCurrencyId(String id);

  @Query('SELECT * FROM Utxo WHERE utxo_id = :id limit 1')
  Future<Utxo> findUtxoById(String id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertUtxo(Utxo utxo);

  @update
  Future<void> updateUtxo(Utxo utxo);

  @insert
  Future<List<int>> insertUtxos(List<Utxo> utxos);
}
