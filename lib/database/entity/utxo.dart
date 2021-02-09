import 'package:floor/floor.dart';

import 'account.dart';

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
}
