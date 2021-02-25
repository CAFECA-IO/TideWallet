import 'package:floor/floor.dart';

import '../entity/utxo.dart';

@dao
abstract class UtxoDao {
  @Query('SELECT * FROM JoinUtxo WHERE JoinUtxo.accountcurrency_id = :id')
  Future<List<JoinUtxo>> findAllJoinedUtxosById(String accountcurrencyId);

  @Query('SELECT * FROM JoinUtxo WHERE JoinUtxo.utxo_id = :id limit 1')
  Future<JoinUtxo> findJoinedUtxoById(String id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertUtxo(UtxoEntity utxo);

  @update
  Future<void> updateUtxo(UtxoEntity utxo);

  @insert
  Future<List<int>> insertUtxos(List<UtxoEntity> utxos);
}
