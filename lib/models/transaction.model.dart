import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui';
import 'package:decimal/decimal.dart';
import 'package:convert/convert.dart';

import '../helpers/logger.dart';
import '../theme.dart';
import '../database/entity/transaction.dart';

class Transaction {
  String id;
  TransactionDirection direction;
  Decimal amount; // in eth
  TransactionStatus status;
  int timestamp; // in second //TODO uncheck
  int confirmations;
  String _address;
  Decimal fee; // in eth
  String txId;
  Uint8List message;
  String sourceAddresses;
  String destinationAddresses;
  Decimal gasPrice; // in Wei
  Decimal gasUsed;

  DateTime get dateTime =>
      DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: false);
  String get address => _address;

  String get messageInString {
    String _message = hex.encode(this.message);
    try {
      // try to read as utf8
      _message = utf8.decode(this.message);
      Log.debug('utf8 message: $message');
    } catch (e) {
      // try to read as ascii
      _message = String.fromCharCodes(this.message);
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

  dynamic get changeUtxo {
    throw UnimplementedError();
  }

  Uint8List get serializeTransaction {
    throw UnimplementedError();
  }

// need update
  Transaction({
    this.id,
    this.direction,
    this.amount,
    this.status,
    this.timestamp,
    this.confirmations,
    String address,
    this.fee,
    this.txId,
    this.message,
  }) : _address = address;

  Transaction.fromTransactionEntity(TransactionEntity entity) {
    id = entity.transactionId;
    txId = entity.txId;
    amount = Decimal.parse(entity.amount);
    fee = Decimal.parse(entity.fee);
    direction = entity.direction == 'move'
        ? TransactionDirection.moved
        : entity.direction == 'send'
            ? TransactionDirection.sent
            : TransactionDirection.received;
    _address = (direction == TransactionDirection.sent)
        ? entity.destinctionAddress
        : entity.sourceAddress;
    confirmations = entity.confirmation;
    timestamp = entity.timestamp;
    message = hex.decode(entity.note);
    status = entity.status == 'pending'
        ? TransactionStatus.pending
        : entity.status == 'success'
            ? TransactionStatus.success
            : TransactionStatus.fail;
  }
}

enum TransactionPriority { slow, standard, fast }

extension TransactionPriorityExt on TransactionPriority {
  int get value {
    switch (this) {
      case TransactionPriority.slow:
        return 0;
      case TransactionPriority.standard:
        return 1;
      case TransactionPriority.fast:
        return 2;
    }
  }
}

enum TransactionDirection {
  sent,
  received,
  moved // this should never happen
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
    }
  }

  String get iconPath {
    switch (this) {
      case TransactionDirection.sent:
        return "assets/images/icons/ic_send_black.png";
        break;
      case TransactionDirection.received:
        return "assets/images/icons/ic_receive_black.png";
        break;
      case TransactionDirection.moved:
        return "assets/images/icons/ic_transfer_in_black.png";
        break;
    }
  }

  String get title {
    switch (this) {
      case TransactionDirection.sent:
        return "send";
        break;
      case TransactionDirection.received:
        return "receive";
        break;
      case TransactionDirection.moved:
        return "move";
        break;
    }
  }

  String get subtitle {
    switch (this) {
      case TransactionDirection.sent:
        return "Transfer to";
        break;
      case TransactionDirection.received:
      case TransactionDirection.moved:
        return "Save to";
        break;
    }
  }

  Color get color {
    switch (this) {
      case TransactionDirection.sent:
        return MyColors.primary_04;
        break;
      case TransactionDirection.received:
        return MyColors.primary_03;
        break;
      case TransactionDirection.moved:
        return MyColors.primary_02;
        break;
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
        break;
      case TransactionStatus.fail:
        return "assets/images/icons/ic_failed_red.png";
        break;
      case TransactionStatus.pending:
        return "assets/images/icons/ic_pending_grey.png";
        break;
    }
  }

  String get title {
    switch (this) {
      case TransactionStatus.success:
        return "compeleted";
        break;
      case TransactionStatus.fail:
        return "transaction_fail";
        break;
      case TransactionStatus.pending:
        return "pending";
        break;
    }
  }

  Color get color {
    switch (this) {
      case TransactionStatus.success:
        return MyColors.secondary_08;
        break;
      case TransactionStatus.fail:
        return MyColors.secondary_09;
        break;
      case TransactionStatus.pending:
        return MyColors.secondary_10;
        break;
    }
  }
}
