import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:convert/convert.dart';

import '../models/bitcoin_transaction.model.dart';
import '../helpers/converter.dart';
import '../database/entity/utxo.dart';

class UnspentTxOut {
  final String id;
  final String accountId;
  final String txId;
  final int vout;
  final BitcoinTransactionType type;
  final String address;
  final Decimal amount; // in currency uint
  final int changeIndex;
  final int keyIndex;
  final Uint8List data; // hex string
  final int timestamp;
  final int decimals;
  bool locked;
  final int? sequence;

  //TEST
  // String scriptPubKey;
  Uint8List? privatekey;
  Uint8List? publickey;

  List<int> get script => data;
  List<int> get hash => data;
  List<int> get signature => data;
  Decimal get amountInSmallestUint =>
      Converter.toCurrencySmallestUnit(this.amount, this.decimals);

  UnspentTxOut({
    required this.id,
    required this.accountId,
    required this.txId,
    required this.vout,
    required this.type,
    required this.address,
    required this.amount, // in currency uint
    required this.changeIndex,
    required this.keyIndex,
    required this.data,
    required this.timestamp,
    required this.locked,
    this.sequence,
    required this.decimals,
    // for transaction only
    this.privatekey,
    this.publickey,
    // this.scriptPubKey,
  });

  UnspentTxOut.fromSmallestUint({
    required this.id,
    required this.accountId,
    required this.txId,
    required this.vout,
    required this.type,
    required this.address,
    required Decimal amount, // in currency uint
    required this.changeIndex,
    required this.keyIndex,
    required this.data,
    required this.timestamp,
    required this.locked,
    this.sequence,
    required this.decimals,
    // for transaction only
    this.privatekey,
    this.publickey,
    // this.scriptPubKey,
  }) : this.amount = Converter.toCurrencyUnit(amount, decimals);

  UnspentTxOut.fromUtxoEntity(JoinUtxo utxo)
      : id = utxo.utxoId,
        accountId = utxo.accountId,
        txId = utxo.txId,
        vout = utxo.vout,
        type = BitcoinTransactionType.values
            .firstWhere((type) => type.value == utxo.type),
        amount =
            Converter.toCurrencyUnit(Decimal.parse(utxo.amount), utxo.decimals),
        changeIndex = utxo.changeIndex,
        keyIndex = utxo.keyIndex,
        data = Uint8List.fromList(hex.decode(utxo.script)),
        timestamp = utxo.timestamp,
        locked = utxo.locked,
        address = utxo.address,
        decimals = utxo.decimals,
        sequence = utxo.sequence;
}
