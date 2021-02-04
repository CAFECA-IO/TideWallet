import 'package:tidewallet3/models/utxo.model.dart';

import 'package:decimal/decimal.dart';

import 'dart:typed_data';

import 'transaction_service.dart';

class TransactionServiceBased extends TransactionService {
  @override
  Future<Uint8List> prepareTransaction(
      bool publish, String to, Decimal amount, Decimal fee, Uint8List message,
      {List<UnspentTxOut> unspentTxOuts, String changeAddress}) {
    // TODO: implement prepareTransaction
    throw UnimplementedError();
  }

  @override
  bool verifyAddress(String address, bool publish) {
    // TODO: implement verifyAddress
    throw UnimplementedError();
  }
}
