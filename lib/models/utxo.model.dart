import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:convert/convert.dart';

import '../models/bitcoin_transaction.model.dart';
import '../helpers/converter.dart';
import '../database/entity/utxo.dart';

class UnspentTxOut {
  final String id;
  final String accountcurrencyId;
  final String txId;
  final int vout;
  final BitcoinTransactionType type;
  final String address;
  final Decimal amount; // in currency uint
  final int chainIndex;
  final int keyIndex;
  final Uint8List data; // hex string
  final int timestamp;
  final int decimals;
  bool locked;
  final int sequence;

  //TEST
  // String scriptPubKey;
  Uint8List privatekey;
  Uint8List publickey;

  List<int> get script => data;
  List<int> get hash => data;
  List<int> get signature => data;
  Decimal get amountInSmallestUint =>
      Converter.toCurrencySmallestUnit(this.amount, this.decimals);

  UnspentTxOut({
    this.id,
    this.accountcurrencyId,
    this.txId,
    this.vout,
    this.type,
    this.address,
    this.amount, // in currency uint
    this.chainIndex,
    this.keyIndex,
    this.data,
    this.timestamp,
    this.locked,
    this.sequence,
    this.decimals,
    // for transaction only
    this.privatekey,
    this.publickey,
    // this.scriptPubKey,
  });

  UnspentTxOut.fromSmallestUint({
    this.id,
    this.accountcurrencyId,
    this.txId,
    this.vout,
    this.type,
    this.address,
    Decimal amount, // in currency uint
    this.chainIndex,
    this.keyIndex,
    this.data,
    this.timestamp,
    this.locked,
    this.sequence,
    this.decimals,
    // for transaction only
    this.privatekey,
    this.publickey,
    // this.scriptPubKey,
  }) : this.amount = Converter.toCurrencyUnit(amount, decimals);

  UnspentTxOut.fromUtxoEntity(JoinUtxo utxo)
      : id = utxo.utxoId,
        accountcurrencyId = utxo.accountcurrencyId,
        txId = utxo.txId,
        vout = utxo.vout,
        type = BitcoinTransactionType.values
            .firstWhere((type) => type.value == utxo.type),
        amount = Decimal.parse(utxo.amount),
        chainIndex = utxo.chainIndex,
        keyIndex = utxo.keyIndex,
        data = hex.decode(utxo.script),
        timestamp = utxo.timestamp,
        locked = utxo.locked,
        address = utxo.address,
        decimals = utxo.decimals,
        sequence = utxo.sequence;
}
