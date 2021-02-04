import 'package:decimal/decimal.dart';

import '../constants/account_config.dart';
import '../models/transaction.model.dart';

abstract class AccountService {
  int syncInterval = 10 * 1000;
  ACCOUNT base;

  void init();
  void start();
  void stop();
  Decimal toCoinUnit(Decimal smallUnit);
  Decimal toSmallUnit(Decimal coinUnit);
  // Decimal calculateFastFee();
  // Decimal calculateStandardFee();
  // Decimal calculateSlowFee();

  Future<String> getReceivingAddress();
  Future<String> getChangingAddress();
  Future<List<dynamic>> getTransactionFee(String hex);
  // Future<Decimal> estimateGasLimit(String hex);

  getTransactions();
  // prepareTransaction();
  publishTransaction();
}
