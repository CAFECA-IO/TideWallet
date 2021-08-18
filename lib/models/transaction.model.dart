import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui';
import 'package:decimal/decimal.dart';
import 'package:convert/convert.dart';

import '../models/utxo.model.dart';
import '../helpers/utils.dart';
import '../helpers/logger.dart';
import '../theme.dart';
import '../database/entity/transaction.dart';

class Transaction {
  late String? id;
  late TransactionDirection direction;
  late Decimal amount; // in eth
  late TransactionStatus? status;
  late int? timestamp; // in second //TODO uncheck
  late int? confirmations;
  late String _address;
  late Decimal fee; // in eth
  late String? txId;
  late Uint8List? message;
  late String sourceAddresses;
  late String destinationAddresses;
  Decimal? gasPrice; // in Wei
  Decimal? gasUsed;
  DateTime? get dateTime => timestamp != null
      ? DateTime.fromMillisecondsSinceEpoch(timestamp! * 1000, isUtc: false)
      : null;
  String get address => _address;

  String get messageInString {
    String _message = hex.encode(this.message!);
    try {
      // try to read as utf8
      _message = utf8.decode(this.message!);
      Log.debug('utf8 message: $message');
    } catch (e) {
      // try to read as ascii
      _message = String.fromCharCodes(this.message!);
      Log.debug('ascii message: $message');
    }
    return _message;
  }

  dynamic get inputs {
    throw UnimplementedError();
  }

  dynamic get outputs {
    throw UnimplementedError();
  }

  UnspentTxOut? get changeUtxo {
    throw UnimplementedError();
  }

  Uint8List get serializeTransaction {
    throw UnimplementedError();
  }

  Transaction();
// need update
  Transaction.base({
    this.id,
    required this.direction,
    required this.amount,
    this.status,
    this.timestamp,
    this.confirmations,
    required String address,
    required this.fee,
    this.txId,
    this.message,
  }) : _address = address;

  Transaction.fromJson(Map json) {
    this.txId = json['txid'];
    this.status = json['status'];
    this.confirmations = json['confirmations'];
    this.amount = json['amount'];
    this.direction = json['direction'];
    this.timestamp = json['timestamp'];
    this.sourceAddresses = json['source_addresses'];
    this.destinationAddresses = json['destination_addresses'];
    this.fee = json['fee'];
    this.message = json['message'];
  }

  Transaction.fromTransactionEntity(TransactionEntity entity) {
    id = entity.transactionId;
    txId = entity.txId;
    amount = Decimal.parse(entity.amount);
    fee = Decimal.parse(entity.fee);
    direction = entity.direction == 'move'
        ? TransactionDirection.moved
        : entity.direction == 'send'
            ? TransactionDirection.sent
            : entity.direction == 'receive'
                ? TransactionDirection.received
                : TransactionDirection.unknown;
    _address = (direction == TransactionDirection.received)
        ? entity.sourceAddress
        : entity.destinctionAddress;
    confirmations = entity.confirmation;
    timestamp = entity.timestamp;
    message = entity.note != null
        ? Uint8List.fromList(hex.decode(stripHexPrefix(entity.note!)))
        : Uint8List(0);
    status = entity.status == 'pending'
        ? TransactionStatus.pending
        : entity.status == 'success'
            ? TransactionStatus.success
            : TransactionStatus.fail;
  }
}

enum TransactionPriority { slow, standard, fast }

extension TransactionPriorityExt on TransactionPriority {
  int get index {
    switch (this) {
      case TransactionPriority.slow:
        return 0;
      case TransactionPriority.standard:
        return 1;
      case TransactionPriority.fast:
        return 2;
    }
  }

  String get value {
    switch (this) {
      case TransactionPriority.slow:
        return 'slow';
      case TransactionPriority.standard:
        return 'standard';
      case TransactionPriority.fast:
        return 'fast';
    }
  }
}

enum TransactionDirection {
  sent,
  received,
  moved, // this should never happen
  unknown
}

extension TransactionDirectionExt on TransactionDirection {
  int get value {
    switch (this) {
      case TransactionDirection.sent:
        return 0;
      case TransactionDirection.received:
        return 1;
      case TransactionDirection.moved:
        return 2;
      case TransactionDirection.unknown:
        return 3;
    }
  }

  String get iconPath {
    switch (this) {
      case TransactionDirection.sent:
        return "assets/images/icons/ic_send_black.png";
      case TransactionDirection.received:
        return "assets/images/icons/ic_receive_black.png";
      case TransactionDirection.moved:
        return "assets/images/icons/ic_transfer_in_black.png";
      case TransactionDirection.unknown:
        return "assets/images/icons/ic_transfer_in_black.png";
    }
  }

  String get title {
    switch (this) {
      case TransactionDirection.sent:
        return "send";
      case TransactionDirection.received:
        return "receive";
      case TransactionDirection.moved:
        return "move";
      case TransactionDirection.unknown:
        return "unknown";
    }
  }

  String get subtitle {
    switch (this) {
      case TransactionDirection.sent:
        return "transfer_to";
      case TransactionDirection.received:
      case TransactionDirection.moved:
        return "receive_from";
      case TransactionDirection.unknown:
        return "Unknown";
    }
  }

  Color get color {
    switch (this) {
      case TransactionDirection.sent:
        return MyColors.primary_04;
      case TransactionDirection.received:
        return MyColors.primary_03;
      case TransactionDirection.moved:
        return MyColors.primary_02;
      case TransactionDirection.unknown:
        return MyColors.primary_02;
    }
  }
}

enum TransactionStatus {
  success,
  fail,
  pending // this should never happen
}

extension TransactionStatueExt on TransactionStatus {
  String get iconPath {
    switch (this) {
      case TransactionStatus.success:
        return "assets/images/icons/ic_completed_green.png";
      case TransactionStatus.fail:
        return "assets/images/icons/ic_failed_red.png";
      case TransactionStatus.pending:
        return "assets/images/icons/ic_pending_grey.png";
    }
  }

  String get title {
    switch (this) {
      case TransactionStatus.success:
        return "compeleted";
      case TransactionStatus.fail:
        return "transaction_fail";
      case TransactionStatus.pending:
        return "pending";
    }
  }

  Color get color {
    switch (this) {
      case TransactionStatus.success:
        return MyColors.secondary_08;
      case TransactionStatus.fail:
        return MyColors.secondary_09;
      case TransactionStatus.pending:
        return MyColors.secondary_10;
    }
  }
}
