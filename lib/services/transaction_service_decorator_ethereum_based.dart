import 'dart:typed_data';
import 'package:decimal/decimal.dart';

import 'transaction_service.dart';
import '../models/utxo.model.dart';

class EthereumBasedTransactionServiceDecorator extends TransactionService {
  final TransactionService service;

  EthereumBasedTransactionServiceDecorator(this.service);

  @override
  Future<Uint8List> prepareTransaction(
      String to, Decimal amount, Decimal fee, Uint8List message, bool publish,
      {List<UnspentTxOut> unspentTxOuts = const []}) {
    // TODO: implement prepareTransaction
    throw UnimplementedError();
  }

  @override
  bool verifyAddress(String address, bool publish) {
    // TODO: implement verifyAddress
    throw UnimplementedError();
  }
}
