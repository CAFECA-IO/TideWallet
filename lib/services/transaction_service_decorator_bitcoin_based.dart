import 'dart:typed_data';
import 'package:decimal/decimal.dart';

import 'transaction_service.dart';
import '../models/utxo.model.dart';
import '../helpers/bitcoin_base_extension.dart';

class BitcoinBasedTransactionServiceDecorator extends TransactionService {
  static const int ADVANCED_TRANSACTION_MARKER = 0x00;
  static const int ADVANCED_TRANSACTION_FLAG = 0x01;
  static const int DEFAULT_SEQUENCE = 0xffffffff;

  static const int OP_0 = 0x00;
  static const int OP_PUSHDATA1 = 0x4c;
  static const int OP_PUSHDATA2 = 0x4d;
  static const int OP_PUSHDATA4 = 0x4e;
  static const int OP_1NEGATE = 0x4f;
  static const int OP_1 = 0x51;
  static const int OP_16 = 0x60;
  static const int OP_DUP = 0x76;
  static const int OP_EQUAL = 0x87;
  static const int OP_EQUALVERIFY = 0x88;
  static const int OP_HASH160 = 0xa9;
  static const int OP_CHECKSIG = 0xac;
  static const int OP_CODESEPARATOR = 0xab;

  final TransactionService service;
  int p2pkhAddressPrefixTestnet;
  int p2pkhAddressPrefixMainnet;
  int p2shAddressPrefixTestnet;
  int p2shAddressPrefixMainnet;
  String bech32HrpMainnet;
  String bech32HrpTestnet;
  String bech32Separator;
  bool supportSegwit = true;

  BitcoinBasedTransactionServiceDecorator(this.service);
  @override
  bool verifyAddress(String address, bool publish) {
    bool verified = isP2pkhAddress(
            address,
            publish
                ? this.p2pkhAddressPrefixMainnet
                : this.p2pkhAddressPrefixTestnet) ||
        isP2shAddress(
            address,
            publish
                ? this.p2shAddressPrefixMainnet
                : this.p2shAddressPrefixTestnet) ||
        isSegWitAddress(
            address,
            publish ? this.bech32HrpMainnet : this.bech32HrpTestnet,
            bech32Separator);
    return verified;
  }

  @override
  Future<Uint8List> prepareTransaction(
      String to, Decimal amount, Decimal fee, Uint8List message, bool publish,
      {List<UnspentTxOut> unspentTxOuts}) {
    // TODO: implement prepareTransaction
    throw UnimplementedError();
  }
}
