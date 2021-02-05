import 'dart:typed_data';
import 'package:decimal/decimal.dart';

import 'transaction_service.dart';
import '../models/utxo.model.dart';

class EthereumBasedTransactionServiceDecorator extends TransactionService {
  final TransactionService service;

  EthereumBasedTransactionServiceDecorator(this.service);

  @override
  Future<Uint8List> prepareTransaction(
      bool publish, String to, Decimal amount, Decimal fee, Uint8List message,
      {List<UnspentTxOut> unspentTxOuts = const [],
      String changeAddress = ''}) {
    // TODO: implement prepareTransaction
    throw UnimplementedError();
  }

  @override
  bool verifyAddress(String address, bool publish) {
    // TODO: implement verifyAddress
    throw UnimplementedError();
  }

  @override
  Decimal calculateTransactionVSize(
      {List<UnspentTxOut> unspentTxOuts,
      Decimal feePerByte,
      Decimal amount,
      Uint8List message}) {
    // TODO: implement calculateTransactionVSize
    throw UnimplementedError();
  }
}
