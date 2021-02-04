import 'dart:typed_data';

import 'package:decimal/decimal.dart';

class UnspentTxOut {
  static const String ClassName = "utxo";
  static const String FieldName_Id = "id";
  static const String FieldName_Network = "network";
  static const String FieldName_AccountId = "account_id";
  static const String FieldName_CurrencyId = "currency_id";
  static const String FieldName_TxId = "txid";
  static const String FieldName_Vout = "vout";
  static const String FieldName_Type = "utxo_type";
  static const String FieldName_Address = "addresses";
  static const String FieldName_Amount = "amount";
  static const String FieldName_ChainIndex = "chain_index";
  static const String FieldName_KeyIndex = "key_index";
  static const String FieldName_Data = "data";
  static const String FieldName_Timestamp = "utxo_timestamp";
  static const String FieldName_Locked = "locked";
  static const String FieldName_Sequence = "sequence";

  final String id;
  int _network;
  final String accountId;
  final String currencyId;
  final String txid;
  final int vout;
  final String type;
  final String address;
  final Decimal amount; // in btc
  final int chainIndex;
  final int keyIndex;
  final Uint8List data; // hex string
  final int timestamp;
  final int locked;

  //TEST
  String scriptPubKey;
  String privatekey;
  String publickey;
  int sequence;

  Map<String, dynamic> get map => {
        FieldName_Id: id,
        FieldName_Network: _network,
        FieldName_AccountId: accountId,
        FieldName_CurrencyId: currencyId,
        FieldName_TxId: txid,
        FieldName_Vout: vout,
        FieldName_Type: type,
        FieldName_Address: address,
        FieldName_Amount: amount,
        FieldName_ChainIndex: chainIndex,
        FieldName_KeyIndex: keyIndex,
        FieldName_Data: data,
        FieldName_Timestamp: timestamp,
        FieldName_Locked: locked,
        FieldName_Sequence: sequence,
      };

  List<int> get script => data;
  List<int> get hash => data;
  List<int> get signature => data;

  List<dynamic> get serializedData {
    List<dynamic> list = [];
    list.add(id);
    list.add(accountId);
    list.add(currencyId);
    list.add(txid);
    list.add(vout);
    list.add(type);
    list.add(address);
    list.add(amount);
    list.add(chainIndex);
    list.add(keyIndex);
    list.add(data);
    list.add(timestamp);
    list.add(locked);
    list.add(_network);
    list.add(sequence);
    return list;
  }

  UnspentTxOut({
    this.id,
    this.accountId,
    this.currencyId,
    this.txid,
    this.vout,
    this.type,
    this.address,
    this.amount,
    this.chainIndex,
    this.keyIndex,
    this.data,
    this.timestamp,
    this.locked,
    //TEST
    this.privatekey,
    this.publickey,
    this.scriptPubKey,
    this.sequence,
  });
  //  : _network = Config().network;

  UnspentTxOut.fromSerializedData(List<dynamic> list)
      : id = list[0],
        accountId = list[1],
        currencyId = list[2],
        txid = list[3],
        vout = list[4],
        type = list[5],
        address = list[6],
        amount = list[7],
        chainIndex = list[8],
        keyIndex = list[9],
        data = list[10],
        timestamp = list[11],
        locked = list[12],
        _network = list[13],
        sequence = list[14];

  UnspentTxOut.fromMap(Map<String, dynamic> map)
      : id = map[FieldName_Id],
        accountId = map[FieldName_AccountId],
        currencyId = map[FieldName_CurrencyId],
        _network = map[FieldName_Network], //?? Config().network,
        txid = map[FieldName_TxId],
        vout = map[FieldName_Vout],
        type = map[FieldName_Type],
        address = map[FieldName_Address],
        amount = map[FieldName_Amount],
        chainIndex = map[FieldName_ChainIndex],
        keyIndex = map[FieldName_KeyIndex],
        data = map[FieldName_Data],
        timestamp = map[FieldName_Timestamp],
        locked = map[FieldName_Locked],
        sequence = map[FieldName_Sequence];
}
