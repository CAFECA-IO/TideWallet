import 'package:floor/floor.dart';

import '../entity/utxo.dart';

@dao
abstract class UtxoDao {
  @Query('SELECT * FROM JoinUtxo WHERE JoinUtxo.account_id = :id')
  Future<List<JoinUtxo>> findAllJoinedUtxosById(String id);

  @Query('SELECT * FROM JoinUtxo')
  Future<List<JoinUtxo>> findAllJoinedUtxos();

  @Query('SELECT * FROM Utxo')
  Future<List<UtxoEntity>> findAllUtxos();

  @Query('SELECT * FROM Utxo WHERE Utxo.account_id = :id')
  Future<List<UtxoEntity>> findAllUtxosById(String id);

  @Query('SELECT * FROM JoinUtxo WHERE JoinUtxo.utxo_id = :id limit 1')
  Future<JoinUtxo?> findJoinedUtxoById(String id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertUtxo(UtxoEntity utxo);

  @update
  Future<void> updateUtxo(UtxoEntity utxo);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertUtxos(List<UtxoEntity> utxos);
}
