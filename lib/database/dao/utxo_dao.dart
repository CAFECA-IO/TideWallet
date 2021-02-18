import 'package:floor/floor.dart';

import '../entity/utxo.dart';

@dao
abstract class UtxoDao {
  @Query('SELECT * FROM Utxo WHERE currency_id = :id')
  Future<List<UtxoEntity>> findAllUtxosByCurrencyId(String id);

  @Query('SELECT * FROM Utxo WHERE utxo_id = :id limit 1')
  Future<UtxoEntity> findUtxoById(String id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertUtxo(UtxoEntity utxo);

  @update
  Future<void> updateUtxo(UtxoEntity utxo);

  @insert
  Future<List<int>> insertUtxos(List<UtxoEntity> utxos);
}
