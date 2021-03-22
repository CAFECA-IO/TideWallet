import 'package:tidewallet3/models/utxo.model.dart';

import 'package:decimal/decimal.dart';

import 'dart:typed_data';

import 'transaction_service.dart';
import '../models/transaction.model.dart';

class TransactionServiceBased extends TransactionService {
  @override
  Transaction prepareTransaction(
      bool publish, String to, Decimal amount, Uint8List message,
      {Decimal fee,
      Decimal gasPrice,
      Decimal gasLimit,
      int nonce,
      int chainId,
      String accountcurrencyId,
      List<UnspentTxOut> unspentTxOuts,
      String changeAddress,
      int changeIndex,
      Uint8List privKey}) {
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

  @override
  Uint8List extractAddressData(String address, bool publish) {
    // TODO: implement extractAddressData
    throw UnimplementedError();
  }
}
