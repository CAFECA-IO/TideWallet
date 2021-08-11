import 'dart:async';

import 'package:decimal/decimal.dart';

import '../constants/account_config.dart';
import '../models/transaction.model.dart';

abstract class AccountService {
  int AVERAGE_FETCH_FEE_TIME = 1 * 60 * 60 * 1000; // milliseconds
  int syncInterval = 10 * 10 * 1000;
  late ACCOUNT? base;
  late int lastSyncTimestamp;
  late String accountId;
  late Timer? timer;

  void init(String id, ACCOUNT base, {int interval});
  Future start();
  void stop();

  Future<List> getReceivingAddress(String currencyId);
  Future<List> getChangingAddress(String currencyId);
  Future<Map<TransactionPriority, Decimal>> getTransactionFee(
      String blockchainId);

  Future<List> publishTransaction(String blockchainId, Transaction transaction);

  Future updateTransaction(String currencyId, Map payload);

  Future updateCurrency(String currencyId, Map payload);

  Future synchro({bool? force});
}
