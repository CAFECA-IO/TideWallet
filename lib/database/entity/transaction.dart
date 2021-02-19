import 'package:floor/floor.dart';

import 'account.dart';

@entity
class TransactionEntity {
  @primaryKey
  @ColumnInfo(name: 'transaction_id')
  final String transactionId;

  @ForeignKey(
      childColumns: ['account_id'],
      parentColumns: ['account_id'],
      entity: AccountEntity)
  @ColumnInfo(name: 'account_id')
  final String accountId;

  @ColumnInfo(name: 'currency_id')
  final String currencyId;

  @ColumnInfo(name: 'tx_id')
  final String txId;

  @ColumnInfo(name: 'source_address')
  final String sourceAddress;

  @ColumnInfo(name: 'destinction_address')
  final String destinctionAddress;

  final int timestamp;

  final int confirmation;

  @ColumnInfo(name: 'gas_price')
  final String gasPrice;

  @ColumnInfo(name: 'gas_used')
  final int gasUsed;


  final int block;

  // final int locktime;

  @ColumnInfo(nullable: false)
  final String fee;

  final String note;

  final String status; // success/pending/fail

  final String direction;

  final String amount;

  TransactionEntity({
    this.transactionId,
    this.accountId,
    this.currencyId,
    this.txId,
    this.confirmation,
    this.sourceAddress,
    this.destinctionAddress,
    this.gasPrice,
    this.gasUsed,
    this.note,
    this.block,
    // this.locktime,
    this.fee,
    this.status,
    this.timestamp,
    this.direction,
    this.amount
  });
}
