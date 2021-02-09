import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui';

import 'package:decimal/decimal.dart';
import 'package:convert/convert.dart';

import '../helpers/logger.dart';
import '../theme.dart';
import './utxo.model.dart';
import './bitcoin_transaction.model.dart';
import './ethereum_transaction.model.dart';
import './ethereum_token_transaction.model.dart';

class Transaction {
  String id;
  TransactionDirection direction;
  Decimal amount; // in eth
  TransactionStatus status;
  int timestamp; // in second
  int confirmations;
  String _address;
  Decimal fee; // in eth
  String txId;
  Uint8List note;

  Map<String, dynamic> _data = {};

  DateTime get dateTime =>
      DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: false);
  String get address => _address;

  String get noteInString {
    String _note = hex.encode(this.note);
    try {
      // try to read as utf8
      _note = utf8.decode(this.note);
      Log.debug('utf8 note: $note');
    } catch (e) {
      // try to read as ascii
      _note = String.fromCharCodes(this.note);
      Log.debug('ascii note: $note');
    }
    return _note;
  }

  List<UnspentTxOut> get utxos => _data["utxos"];
  List<int> get rlpData => _data["rawTx"];
  List<int> get rawTx => _data["rawTx"];

  set utxos(List<UnspentTxOut> utxos) {
    _data["utxos"] = utxos;
  }

  set rlpData(List<int> data) {
    _data["rawTx"] = data;
  }

  set rawTx(List<int> data) {
    _data["rawTx"] = data;
  }

  List<dynamic> get serializedData {
    List<dynamic> list = [];
    list.add(direction.value); //0
    list.add(amount); //1
    list.add(status); //2
    list.add(timestamp); //3
    list.add(confirmations); //4
    list.add(address); //5
    list.add(fee); //6
    list.add(txId); //7
    list.add(note); //8
    list.add(_data["rawTx"]); //9

    List<UnspentTxOut> utxos = _data["utxos"];
    if (utxos == null) return list;
    List<List<dynamic>> utxoList =
        List.generate(utxos.length, (index) => utxos[index].serializedData);
    list.add(utxoList);

    return list;
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
    this.note,
  }) : _address = address;

  Transaction.fromSerializedData(List<dynamic> data) {
    // PBLog.debug('data: $data');
    direction = TransactionDirection.values
        .where((element) => (element.value == data[0]))
        .first;
    amount = data[1];
    status = data[2];
    timestamp = data[3];
    confirmations = data[4];
    _address = data[5];
    fee = data[6];
    txId = data[7];
    note = data[8];
    _data["rawTx"] = data[9];

    if (data.length > 11) {
      List<List<dynamic>> utxoList = data[10]; // ?
      List<UnspentTxOut> utxos = List.generate(utxoList.length,
          (index) => UnspentTxOut.fromSerializedData(utxoList[index]));
      _data["utxos"] = utxos;
    }
  }

  Transaction.fromBitcoinTransaction(BitcoinTransaction transaction) {
    txId = transaction.txid;
    amount = transaction.amount;
    timestamp = transaction.timestamp;
    confirmations = transaction.confirmations;

    fee = transaction.fee;
    direction = transaction.direction;
    _address = (direction == TransactionDirection.sent)
        ? transaction.destinationAddresses
        : transaction.sourceAddresses;
  }

  Transaction.fromEthereumTransaction(EthereumTransaction transaction) {
    txId = transaction.txHash;
    amount = transaction.amount;
    timestamp = transaction.timestamp;
    confirmations = transaction.confirmations;

    // var gasPrice = BigInt.parse(transaction.gasPrice.toString());
    // var gasUsed = BigInt.from(transaction.gasUsed.toInt());
    // var feeWei = gasPrice * gasUsed;
    // // _fee = _account.toCoinUnit(feeWei).toString();
  }

  Transaction.fromEthereumTokenTransaction(
      EthereumTokenTransaction transaction) {
    txId = transaction.txHash;
    amount = transaction.amount;
    timestamp = transaction.timestamp;
    confirmations = 1; // useless to token
    fee = Decimal.zero; // useless to token
    direction = TransactionDirection.sent;
    _address = (direction == TransactionDirection.sent)
        ? transaction.to
        : transaction.from;
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
