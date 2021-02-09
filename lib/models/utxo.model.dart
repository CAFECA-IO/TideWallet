import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:convert/convert.dart';

import '../database/entity/utxo.dart' as UtxoEntity;

class UnspentTxOut {
  static const String ClassName = "utxo";
  static const String FieldName_CurrencyId = "currency_id";
  static const String FieldName_Id = "id";
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
  final String currencyId;
  final String txid;
  final int vout;
  final String type;
  // final String address;
  final Decimal amount; // in btc
  final int chainIndex;
  final int keyIndex;
  final Uint8List data; // hex string
  final int timestamp;
  final bool locked;
  final int sequence;

  //TEST
  // String scriptPubKey;
  Uint8List privatekey;
  Uint8List publickey;

  Map<String, dynamic> get map => {
        FieldName_Id: id,
        FieldName_CurrencyId: currencyId,
        FieldName_TxId: txid,
        FieldName_Vout: vout,
        FieldName_Type: type,
        // FieldName_Address: address,
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
    list.add(currencyId);
    list.add(txid);
    list.add(vout);
    list.add(type);
    // list.add(address);
    list.add(amount);
    list.add(chainIndex);
    list.add(keyIndex);
    list.add(data);
    list.add(timestamp);
    list.add(locked);
    list.add(sequence);
    return list;
  }

  UnspentTxOut({
    this.id,
    this.currencyId,
    this.txid,
    this.vout,
    this.type,
    // this.address,
    this.amount,
    this.chainIndex,
    this.keyIndex,
    this.data,
    this.timestamp,
    this.locked,
    this.sequence,
    // for transaction only
    this.privatekey,
    this.publickey,
    // this.scriptPubKey,
  });
  //  : _network = Config().network;

  UnspentTxOut.fromSerializedData(List<dynamic> list)
      : id = list[0],
        currencyId = list[1],
        txid = list[2],
        vout = list[3],
        type = list[4],
        // address = list[5],
        amount = list[5],
        chainIndex = list[6],
        keyIndex = list[7],
        data = list[8],
        timestamp = list[9],
        locked = list[10],
        sequence = list[11];

  UnspentTxOut.fromMap(Map<String, dynamic> map)
      : id = map[FieldName_Id],
        currencyId = map[FieldName_CurrencyId],
        txid = map[FieldName_TxId],
        vout = map[FieldName_Vout],
        type = map[FieldName_Type],
        // address = map[FieldName_Address],
        amount = map[FieldName_Amount],
        chainIndex = map[FieldName_ChainIndex],
        keyIndex = map[FieldName_KeyIndex],
        data = map[FieldName_Data],
        timestamp = map[FieldName_Timestamp],
        locked = map[FieldName_Locked],
        sequence = map[FieldName_Sequence];

  UnspentTxOut.fromUtxoEntity(UtxoEntity.Utxo utxo)
      : id = utxo.utxoId,
        currencyId = utxo.currencyId,
        txid = utxo.txId,
        vout = utxo.vout,
        type = utxo.type,
        amount = Decimal.parse(utxo.amount),
        chainIndex = utxo.chainIndex,
        keyIndex = utxo.keyIndex,
        data = hex.decode(utxo.script),
        timestamp = utxo.timestamp,
        locked = utxo.locked,
        sequence = utxo.sequence;
}
