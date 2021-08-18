import 'package:tidewallet3/models/utxo.model.dart';

import 'package:decimal/decimal.dart';

import 'dart:typed_data';

import 'transaction_service.dart';
import '../models/transaction.model.dart';

class TransactionServiceBased extends TransactionService {
  @override
  Future<Transaction> prepareTransaction(
    String thirdPartyId,
    bool isMainet,
    String to,
    Decimal amount, {
    String? message,
    Decimal? fee,
    Decimal? gasPrice,
    Decimal? gasLimit,
    int? nonce,
    int? chainId,
    String? accountId,
    List<UnspentTxOut>? unspentTxOuts,
    String? changeAddress,
    int? keyIndex,
  }) {
    // TODO: implement prepareTransaction
    throw UnimplementedError();
  }

  @override
  bool verifyAddress(String address, bool publish) {
    // TODO: implement verifyAddress
    throw UnimplementedError();
  }

  @override
  Uint8List extractAddressData(String address, bool publish) {
    // TODO: implement extractAddressData
    throw UnimplementedError();
  }
}
