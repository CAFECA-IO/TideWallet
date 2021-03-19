import 'package:floor/floor.dart';
import 'package:convert/convert.dart';

import 'account_currency.dart';
import '../../models/utxo.model.dart';
import '../../models/bitcoin_transaction.model.dart';

@Entity(
  tableName: 'Utxo',
  foreignKeys: [
    ForeignKey(
      childColumns: ['accountcurrency_id'],
      parentColumns: ['accountcurrency_id'],
      entity: AccountCurrencyEntity,
      onDelete: ForeignKeyAction.cascade,
    )
  ],
)
class UtxoEntity {
  @primaryKey
  @ColumnInfo(name: 'utxo_id', nullable: false)
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
        this.type = _utxo.type.value,
        this.amount = _utxo.amount.toString(),
        this.chainIndex = _utxo.chainIndex,
        this.keyIndex = _utxo.keyIndex,
        this.script = hex.encode(_utxo.data),
        this.timestamp = _utxo.timestamp,
        this.locked = _utxo.locked,
        this.sequence = _utxo.sequence,
        this.address = _utxo.address;

  UtxoEntity.fromJson(String accountId, Map<String, dynamic> data)
      : this.utxoId = data['utxo_id'],
        this.accountcurrencyId = accountId,
        this.txId = data['txid'],
        this.vout = data['vout'],
        this.type = data['type'],
        this.amount = data['amount'],
        this.chainIndex = data['chain_index'],
        this.keyIndex = data['key_index'],
        this.script = data['script'],
        this.timestamp = data['timestamp'],
        this.locked = false,
        this.sequence = BitcoinTransaction.DEFAULT_SEQUENCE,
        this.address = data['address'];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UtxoEntity &&
          utxoId == other.utxoId &&
          accountcurrencyId == other.accountcurrencyId &&
          txId == other.txId &&
          vout == other.vout &&
          type == other.type &&
          amount == other.amount &&
          chainIndex == other.chainIndex &&
          keyIndex == other.keyIndex &&
          script == other.script &&
          timestamp == other.timestamp &&
          locked == other.locked &&
          sequence == other.sequence &&
          address == other.address;
}

@DatabaseView(
    'SELECT * FROM Utxo INNER JOIN AccountCurrency ON Utxo.accountcurrency_id = AccountCurrency.accountcurrency_id INNER JOIN Currency ON AccountCurrency.currency_id = Currency.currency_id',
    viewName: 'JoinUtxo')
class JoinUtxo {
  @ColumnInfo(name: 'utxo_id', nullable: false)
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
        this.type = _utxo.type.value,
        this.amount = _utxo.amount.toString(),
        this.chainIndex = _utxo.chainIndex,
        this.keyIndex = _utxo.keyIndex,
        this.script = hex.encode(_utxo.script),
        this.timestamp = _utxo.timestamp,
        this.locked = _utxo.locked,
        this.sequence = _utxo.sequence,
        this.decimals = _utxo.decimals,
        this.address = _utxo.address;
}
