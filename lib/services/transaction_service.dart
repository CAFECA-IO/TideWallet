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
  Decimal calculateTransactionVSize(
      {required List<UnspentTxOut> unspentTxOuts,
      required Decimal feePerByte,
      required Decimal amount,
      Uint8List? message});
  Transaction prepareTransaction(
      bool publish, String to, Decimal amount, Uint8List message,
      {Decimal? fee,
      Decimal? gasPrice,
      Decimal? gasLimit,
      int? nonce,
      int? chainId,
      String? accountId,
      List<UnspentTxOut>? unspentTxOuts,
      String? changeAddress,
      int? keyIndex,
      Uint8List? privKey});
}
