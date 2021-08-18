import 'dart:typed_data';
import 'package:decimal/decimal.dart';

import '../models/utxo.model.dart';
import '../models/transaction.model.dart';
import '../constants/account_config.dart';

abstract class TransactionService {
  late ACCOUNT base;
  late int currencyDecimals;

  bool verifyAddress(String address, bool publish);
  dynamic extractAddressData(String address, bool publish);
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
  });
}
