import 'package:decimal/decimal.dart';

import '../constants/account_config.dart';
abstract class AccountService {
  int syncInterval = 10 * 1000;
  ACCOUNT base;

  void init();
  void start();
  void stop();
  Decimal toCoinUnit();
  Decimal toSmallUnit();
  Decimal calculateFastDee();
  Decimal calculateStandardDee();
  Decimal calculateSlowDee();

  getTransactions();
  prepareTransaction();
  publishTransaction();
}