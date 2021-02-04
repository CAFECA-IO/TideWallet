import 'dart:typed_data';
import 'package:decimal/decimal.dart';

import '../models/utxo.model.dart';
import '../constants/account_config.dart';

abstract class TransactionService {
  ACCOUNT base;

  bool verifyAddress(String address, bool publish);
  Future<Uint8List> prepareTransaction(
      String to, Decimal amount, Decimal fee, Uint8List message, bool publish,
      {List<UnspentTxOut> unspentTxOuts});
}
