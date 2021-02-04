import 'package:tidewallet3/models/utxo.model.dart';

import 'package:decimal/decimal.dart';

import 'dart:typed_data';

import 'transaction_service.dart';

class TransactionServiceBased extends TransactionService {
  @override
  Future<Uint8List> prepareTransaction(
      String to, Decimal amount, Decimal fee, Uint8List message, bool publish,
      {List<UnspentTxOut> unspentTxOuts}) {
    // TODO: implement prepareTransaction
    throw UnimplementedError();
  }

  @override
  bool verifyAddress(String address, bool publish) {
    // TODO: implement verifyAddress
    throw UnimplementedError();
  }
}
