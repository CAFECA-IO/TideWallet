import 'package:floor/floor.dart';
import 'package:convert/convert.dart';

import 'account.dart';
import '../../models/utxo.model.dart';


@Entity(tableName: 'Utxo')
class UtxoEntity {
  @primaryKey
  @ColumnInfo(name: 'utxo_id')
  final String utxoId;

  @ForeignKey(
      childColumns: ['account_id'],
      parentColumns: ['account_id'],
      entity: AccountEntity)
  // @ColumnInfo(name: 'account_id')
  // final String accountId;

  @ColumnInfo(name: 'currency_id')
  final String currencyId;

  @ColumnInfo(name: 'tx_id')
  final String txId;

  final int vout;

  final String type;

  final String amount;

  @ColumnInfo(name: 'chain_index')
  final int chainIndex;

  @ColumnInfo(name: 'key_index')
  final int keyIndex;

  final String script;

  final int timestamp;

  final bool locked;

  final int sequence;

  UtxoEntity(
      this.utxoId,
      // this.accountId,
      this.currencyId,
      this.txId,
      this.vout,
      this.type,
      this.amount,
      this.chainIndex,
      this.keyIndex,
      this.script,
      this.timestamp,
      this.locked,
      this.sequence);

  UtxoEntity.fromUnspentUtxo(UnspentTxOut _utxo)
      : this.utxoId = _utxo.id,
        this.currencyId = _utxo.currencyId,
        this.txId = _utxo.txId,
        this.vout = _utxo.vout,
        this.type = _utxo.type.toString(),
        this.amount = _utxo.amount.toString(),
        this.chainIndex = _utxo.chainIndex,
        this.keyIndex = _utxo.keyIndex,
        this.script = hex.encode(_utxo.script),
        this.timestamp = _utxo.timestamp,
        this.locked = true,
        this.sequence = _utxo.sequence;
}
