import 'package:floor/floor.dart';
import 'package:convert/convert.dart';

import 'account.dart';
import '../../models/utxo.model.dart';
import '../../models/bitcoin_transaction.model.dart';

@entity
class Utxo {
  @primaryKey
  @ColumnInfo(name: 'utxo_id')
  final String utxoId;

  @ForeignKey(
      childColumns: ['account_id'],
      parentColumns: ['account_id'],
      entity: Account)
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

  Utxo(
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

  Utxo.locked(Utxo _utxo)
      : this.utxoId = _utxo.utxoId,
        this.currencyId = _utxo.currencyId,
        this.txId = _utxo.txId,
        this.vout = _utxo.vout,
        this.type = _utxo.type,
        this.amount = _utxo.amount,
        this.chainIndex = _utxo.chainIndex,
        this.keyIndex = _utxo.keyIndex,
        this.script = _utxo.script,
        this.timestamp = _utxo.timestamp,
        this.locked = true,
        this.sequence = _utxo.sequence;

  Utxo.fromUnspentUtxo(UnspentTxOut _utxo)
      : this.utxoId = _utxo.id,
        this.currencyId = _utxo.currencyId,
        this.txId = _utxo.txId,
        this.vout = _utxo.vout,
        this.type = _utxo.type.value,
        this.amount = _utxo.amount.toString(),
        this.chainIndex = _utxo.chainIndex,
        this.keyIndex = _utxo.keyIndex,
        this.script = hex.encode(_utxo.script),
        this.timestamp = _utxo.timestamp,
        this.locked = true,
        this.sequence = _utxo.sequence;
}
