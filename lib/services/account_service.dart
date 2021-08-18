import 'dart:async';

import 'package:decimal/decimal.dart';

import '../constants/account_config.dart';
import '../models/transaction.model.dart';

abstract class AccountService {
  int AVERAGE_FETCH_FEE_TIME = 1 * 60 * 60 * 1000; // milliseconds
  int syncInterval = 10 * 10 * 1000;
  ACCOUNT? base;
  int? lastSyncTimestamp;
  String? shareAccountId;
  Timer? timer;

  void init(String id, ACCOUNT base, {int interval});
  Future start();
  void stop();

  Future<String> getReceivingAddress();
  Future<Map> getChangingAddress();

  Future<Map> getTransactionFee({
    required String blockchainId,
    required int decimals,
    String? to,
    String? amount,
    String? message,
    TransactionPriority? priority,
  });

  Future<List> publishTransaction(String blockchainId, Transaction transaction);

  Future updateTransaction(String id, Map payload);

  Future updateAccount(String id, Map payload);

  Future synchro({bool? force});

  Future<List<Transaction>> getTrasnctions(String id);
  Future<Transaction> getTransactionDetail(String txid);
}
