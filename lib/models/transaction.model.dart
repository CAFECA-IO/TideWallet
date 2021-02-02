import 'dart:typed_data';
import 'dart:ui';

import '../theme.dart';
import './utxo.model.dart';
import './bitcoin_transaction.model.dart';
import './ethereum_transaction.model.dart';
import './ethereum_token_transaction.model.dart';

class Transaction {
  String id;
  TransactionDirection _direction;
  String _amount; // in eth
  TransactionStatus _status;
  int _timestamp; // in second
  int _confirmations;
  String _address;
  String _fee; // in eth
  String _txId;
  Uint8List _note;

  Map<String, dynamic> _data = {};

  TransactionDirection get direction => _direction;
  String get amount => _amount;
  TransactionStatus get status => _status;
  String get fee => _fee;
  int get confirmations => _confirmations;
  DateTime get timestamp =>
      DateTime.fromMillisecondsSinceEpoch(_timestamp, isUtc: false);
  String get address => _address;
  String get txId => _txId;
  Uint8List get note => _note ?? Uint8List(0);

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
    list.add(_direction.value); //0
    list.add(_amount); //1
    list.add(_status); //2
    list.add(_timestamp); //3
    list.add(_confirmations); //4
    list.add(_address); //5
    list.add(_fee); //6
    list.add(_txId); //7
    list.add(_note); //8
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
    String id,
    TransactionDirection direction,
    String amount,
    TransactionStatus status,
    int timestamp,
    int confirmations,
    String address,
    String fee,
    String txId,
    Uint8List note,
  })  : _txId = txId,
        _direction = direction,
        _address = address,
        _confirmations = confirmations,
        _status = status,
        _amount = amount,
        _fee = fee,
        _timestamp = timestamp,
        _note = note;

  Transaction.fromSerializedData(List<dynamic> data) {
    // PBLog.debug('data: $data');
    _direction = TransactionDirection.values
        .where((element) => (element.value == data[0]))
        .first;
    _amount = data[1];
    _status = data[2];
    _timestamp = data[3];
    _confirmations = data[4];
    _address = data[5];
    _fee = data[6];
    _txId = data[7];
    _note = data[8];
    _data["rawTx"] = data[9];

    if (data.length > 11) {
      List<List<dynamic>> utxoList = data[10]; // ?
      List<UnspentTxOut> utxos = List.generate(utxoList.length,
          (index) => UnspentTxOut.fromSerializedData(utxoList[index]));
      _data["utxos"] = utxos;
    }
  }

  Transaction.fromBitcoinTransaction(BitcoinTransaction transaction) {
    _txId = transaction.txid;
    _amount = transaction.amount.toString();
    _timestamp = transaction.timestamp;
    _confirmations = transaction.confirmations;

    _fee = transaction.fee.toString();
    _direction = transaction.direction;
    _address = (_direction == TransactionDirection.sent)
        ? transaction.destinationAddresses
        : transaction.sourceAddresses;
  }

  Transaction.fromEthereumTransaction(EthereumTransaction transaction) {
    _txId = transaction.txHash;
    _amount = transaction.amount;
    _timestamp = transaction.timestamp;
    _confirmations = transaction.confirmations;

    var gasPrice = BigInt.parse(transaction.gasPrice);
    var gasUsed = BigInt.from(transaction.gasUsed);
    var feeWei = gasPrice * gasUsed;
    // _fee = _account.toCoinUnit(feeWei).toString();
  }

  Transaction.fromEthereumTokenTransaction(
      EthereumTokenTransaction transaction) {
    _txId = transaction.txHash;
    _amount = transaction.amount;
    _timestamp = transaction.timestamp;
    _confirmations = 1; // useless to token
    _fee = "0"; // useless to token
    _direction = TransactionDirection.sent;
    _address = (_direction == TransactionDirection.sent)
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
