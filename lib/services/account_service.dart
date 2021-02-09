import 'package:decimal/decimal.dart';

import '../constants/account_config.dart';
abstract class AccountService {
  int syncInterval = 10 * 10 * 1000;
  ACCOUNT base;

  void init(String id, ACCOUNT base, { int interval });
  void start();
  void stop();
  Decimal toCoinUnit();
  Decimal toSmallUnit();
  Decimal calculateFastDee();
  Decimal calculateStandardDee();
  Decimal calculateSlowDee();
  Future<String> getReceivingAddress();

  getTransactions();
  prepareTransaction();
  publishTransaction();
  
}
