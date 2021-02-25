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
      childColumns: ['accountcurrency_id'],
      parentColumns: ['accountcurrency_id'],
      entity: AccountEntity)
  @ColumnInfo(name: 'accountcurrency_id')
  final String accountcurrencyId;

  @ColumnInfo(name: 'tx_id')
  final String txId;

  final int vout;

  final String type;

  final String amount; // TODO in smallest

  @ColumnInfo(name: 'chain_index')
  final int chainIndex;

  @ColumnInfo(name: 'key_index')
  final int keyIndex;

  final String script;

  final int timestamp;

  final bool locked;

  final int sequence;

  final String address;

  UtxoEntity(
      this.utxoId,
      this.accountcurrencyId,
      this.txId,
      this.vout,
      this.type,
      this.amount,
      this.chainIndex,
      this.keyIndex,
      this.script,
      this.timestamp,
      this.locked,
      this.address,
      this.sequence);

  UtxoEntity.fromUnspentUtxo(UnspentTxOut _utxo)
      : this.utxoId = _utxo.id,
        this.accountcurrencyId = _utxo.accountcurrencyId,
        this.txId = _utxo.txId,
        this.vout = _utxo.vout,
        this.type = _utxo.type.toString(),
        this.amount = _utxo.amount.toString(),
        this.chainIndex = _utxo.chainIndex,
        this.keyIndex = _utxo.keyIndex,
        this.script = hex.encode(_utxo.data),
        this.timestamp = _utxo.timestamp,
        this.locked = true,
        this.sequence = _utxo.sequence,
        this.address = _utxo.address;
}

@DatabaseView(
    'SELECT * FROM Utxo INNER JOIN AccountCurrency ON Utxo.accountcurrency_id = AccountCurrency.accountcurrency_id INNER JOIN Currency ON AccountCurrency.currency_id = Currency.currency_id',
    viewName: 'JoinUtxo')
class JoinUtxo {
  final String utxoId;
  @ColumnInfo(name: 'accountcurrency_id')
  final String accountcurrencyId;

  @ColumnInfo(name: 'tx_id')
  final String txId;

  final int vout;

  final String type;

  final String amount; // TODO in smallest

  @ColumnInfo(name: 'chain_index')
  final int chainIndex;

  @ColumnInfo(name: 'key_index')
  final int keyIndex;

  final String script;

  final int timestamp;

  final bool locked;

  final int sequence;

  final String address;

  final int decimals;

  JoinUtxo(
      this.utxoId,
      this.accountcurrencyId,
      this.txId,
      this.vout,
      this.type,
      this.amount,
      this.chainIndex,
      this.keyIndex,
      this.script,
      this.timestamp,
      this.locked,
      this.sequence,
      this.address,
      this.decimals);

  JoinUtxo.fromUnspentUtxo(UnspentTxOut _utxo)
      : this.utxoId = _utxo.id,
        this.accountcurrencyId = _utxo.accountcurrencyId,
        this.txId = _utxo.txId,
        this.vout = _utxo.vout,
        this.type = _utxo.type.toString(),
        this.amount = _utxo.amount.toString(),
        this.chainIndex = _utxo.chainIndex,
        this.keyIndex = _utxo.keyIndex,
        this.script = hex.encode(_utxo.script),
        this.timestamp = _utxo.timestamp,
        this.locked = true,
        this.sequence = _utxo.sequence,
        this.decimals = _utxo.decimals,
        this.address = _utxo.address;
}
