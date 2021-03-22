import 'dart:async';

import 'package:decimal/decimal.dart';

import '../constants/account_config.dart';
import '../models/transaction.model.dart';
import '../models/utxo.model.dart';

abstract class AccountService {
  int AVERAGE_FETCH_FEE_TIME = 1 * 60 * 60 * 1000; // milliseconds
  int syncInterval = 10 * 10 * 1000;
  ACCOUNT base;
  int lastSyncTimestamp;
  String accountId;
  Timer timer;

  void init(String id, ACCOUNT base, {int interval});
  Future start();
  void stop();

  Future<List> getReceivingAddress(String currencyId);
  Future<List> getChangingAddress(String currencyId);
  Future<Map<TransactionPriority, Decimal>> getTransactionFee(
      String blockchainId);
  Future<Decimal> estimateGasLimit(
      String blockchainId, String from, String to, String amount, String data);
  Future<int> getNonce(String blockchainId, String address);
  Future<List<UnspentTxOut>> getUnspentTxOut(String currencyId);

  getTransactions();

  Future<List> publishTransaction(String blockchainId, Transaction transaction);

  Future synchro();
}
