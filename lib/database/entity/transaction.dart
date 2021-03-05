import 'dart:convert';

import 'package:floor/floor.dart';

import 'account_currency.dart';

@Entity(tableName: '_Transaction')
class TransactionEntity {
  @primaryKey
  @ColumnInfo(name: 'transaction_id')
  final String transactionId;

  @ForeignKey(
      childColumns: ['accountcurrency_id'],
      parentColumns: ['accountcurrency_id'],
      entity: AccountCurrencyEntity)
  @ColumnInfo(name: 'accountcurrency_id')
  final String accountcurrencyId;

  @ColumnInfo(name: 'tx_id')
  final String txId;

  @ColumnInfo(name: 'source_address')
  String sourceAddress;

  @ColumnInfo(name: 'destinction_address')
  String destinctionAddress;

  final int timestamp;

  final int confirmation;

  @ColumnInfo(name: 'gas_price')
  final String gasPrice;

  @ColumnInfo(name: 'gas_used')
  final int gasUsed;

  // final int block;

  // final int locktime;

  @ColumnInfo(nullable: false)
  final String fee;

  final String note;

  final String status; // success/pending/fail

  final String direction;

  final String amount;

  TransactionEntity(
      {this.transactionId,
      this.accountcurrencyId,
      this.txId,
      this.confirmation,
      this.sourceAddress,
      this.destinctionAddress,
      this.gasPrice,
      this.gasUsed,
      this.note,
      // this.block,
      // this.locktime,
      this.fee,
      this.status,
      this.timestamp,
      this.direction,
      this.amount});

  TransactionEntity.fromJson(
      String accountcurrencyId, Map<String, dynamic> data)
      : this.accountcurrencyId = accountcurrencyId,
        this.transactionId = data['txid'],
        this.amount = data['amount'].toString(),
        this.txId = data['txid'],
        this.sourceAddress = data['source_addresses'],
        this.destinctionAddress = data['destination_addresses'],
        this.confirmation = data['confirmations'],
        this.gasPrice = data['gas_price'],
        this.gasUsed = data['gas_limit'],
        this.fee = data['fee'].toString(),
        this.direction = data['direction'],
        this.status = data['status'],
        this.timestamp = data['timestamp'],
        this.note = data['note'];
  //     {
  // List sourceAddress =
  //     data['source_addresses']; // json.decode(data['source_addresses']);
  // List destinctionAddress = data[
  //     'destination_addresses']; //json.decode(data['destination_addresses']);
  // for (var address in sourceAddress) {
  //   this.sourceAddress = this.sourceAddress == null
  //       ? this.sourceAddress = address
  //       : this.sourceAddress += '${", " + address}';
  // }
  // for (var address in destinctionAddress) {
  //   this.destinctionAddress = this.destinctionAddress == null
  //       ? this.destinctionAddress = address
  //       : this.destinctionAddress += '${", " + address}';
  // }
  // }
}
