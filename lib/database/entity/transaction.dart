import 'package:convert/convert.dart';
import 'package:floor/floor.dart';

import 'account.dart';
import '../../models/transaction.model.dart';
import '../../models/account.model.dart';

@Entity(tableName: '_Transaction')
class TransactionEntity {
  @primaryKey
  @ColumnInfo(name: 'transaction_id')
  final String transactionId;

  @ForeignKey(
      childColumns: ['account_id'],
      parentColumns: ['id'],
      entity: AccountEntity)
  @ColumnInfo(name: 'account_id')
  final String accountId;

  @ColumnInfo(name: 'tx_id')
  final String txId;

  @ColumnInfo(name: 'source_address')
  String sourceAddress;

  @ColumnInfo(name: 'destinction_address')
  String destinctionAddress;

  final int? timestamp;

  final int confirmation;

  @ColumnInfo(name: 'gas_price')
  final String? gasPrice;

  @ColumnInfo(name: 'gas_used')
  final int? gasUsed;

  // final int block;

  // final int locktime;

  // @ColumnInfo(nullable: false)
  final String fee;

  final String? note;

  final String status; // success/pending/fail

  final String direction;

  final String amount;

  TransactionEntity({
    required this.transactionId,
    required this.accountId,
    required this.txId,
    required this.confirmation,
    required this.sourceAddress,
    required this.destinctionAddress,
    this.gasPrice,
    this.gasUsed,
    this.note,
    // this.block,
    // this.locktime,
    required this.fee,
    required this.status,
    required this.timestamp,
    required this.direction,
    required this.amount,
  });

  TransactionEntity.fromJson(String accountId, Map data)
      : this.accountId = accountId,
        this.transactionId = accountId + data['txid'],
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

  TransactionEntity.fromTransaction(Account account, Transaction transaction,
      String amount, String fee, String gasPrice, String? destinationAddresses)
      : this.accountId = account.id,
        this.transactionId = account.id + transaction.txId!,
        this.amount = amount, // in smallest coin unit
        this.txId = transaction.txId!,
        this.sourceAddress = transaction.sourceAddresses,
        this.destinctionAddress =
            destinationAddresses ?? transaction.destinationAddresses,
        this.confirmation = transaction.confirmations!,
        this.gasPrice = gasPrice, // in smallest parentCoin unit
        this.gasUsed = transaction.gasUsed?.toInt(),
        this.fee = fee, // in smallest parentCoin unit
        this.direction = transaction.direction.title,
        this.status = transaction.status!.title,
        this.timestamp = transaction.timestamp!,
        this.note = hex.encode(transaction.message!);
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
