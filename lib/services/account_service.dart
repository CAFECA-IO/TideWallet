import 'package:decimal/decimal.dart';

import '../constants/account_config.dart';
import '../models/transaction.model.dart';
import '../models/utxo.model.dart';

abstract class AccountService {
  int syncInterval = 10 * 1000;
  ACCOUNT base;

  void init();
  void start();
  void stop();
  // Decimal toCoinUnit(Decimal smallUnit);
  // Decimal toSmallUnit(Decimal coinUnit);
  // Decimal calculateFastFee();
  // Decimal calculateStandardFee();
  // Decimal calculateSlowFee();

  Future<String> getReceivingAddress(String currencyId);
  Future<String> getChangingAddress(String currencyId);
  Future<Map<TransactionPriority, Decimal>> getTransactionFee();
  Future<Decimal> estimateGasLimit(String hex);
  Future<List<UnspentTxOut>> getUnspentTxOut(String currencyId);

  getTransactions();
  // prepareTransaction();
  Future<void> publishTransaction(
      String blockchainId, String currencyId, Transaction transaction);
}
