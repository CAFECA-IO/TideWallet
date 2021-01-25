import 'package:decimal/decimal.dart';

abstract class AccountService {
  int syncInterval = 10 * 1000;

  void init();
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
