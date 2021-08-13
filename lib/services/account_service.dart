import 'dart:async';

import 'package:decimal/decimal.dart';

import '../constants/account_config.dart';
import '../models/transaction.model.dart';

abstract class AccountService {
  int AVERAGE_FETCH_FEE_TIME = 1 * 60 * 60 * 1000; // milliseconds
  int syncInterval = 10 * 10 * 1000;
  late ACCOUNT base;
  late int lastSyncTimestamp;
  late String shareAccountId;
  late Timer timer;

  void init(String id, ACCOUNT base, {int interval});
  Future start();
  void stop();

  Future<List> getReceivingAddress(String shareAccountId);
  Future<List> getChangingAddress(String shareAccountId);
  Future<Map<TransactionPriority, Decimal>> getTransactionFee(
      String blockchainId);

  Future<List> publishTransaction(String blockchainId, Transaction transaction);

  Future updateTransaction(String accountId, Map payload);

  Future updateAccount(String accountId, Map payload);

  Future synchro({bool? force});
}
