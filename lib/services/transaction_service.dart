import 'dart:typed_data';
import 'package:decimal/decimal.dart';

import '../models/utxo.model.dart';
import '../models/transaction.model.dart';
import '../constants/account_config.dart';

abstract class TransactionService {
  ACCOUNT base;
  int currencyDecimals;

  bool verifyAddress(String address, bool publish);
  Decimal calculateTransactionVSize(
      {List<UnspentTxOut> unspentTxOuts,
      Decimal feePerByte,
      Decimal amount,
      Uint8List message});
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
      Uint8List privKey});
}
