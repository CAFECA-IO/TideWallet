import 'package:decimal/decimal.dart';

import '../constants/account_config.dart';
import '../models/transaction.model.dart';
import '../models/utxo.model.dart';

abstract class AccountService {
  int syncInterval = 10 * 10 * 1000;
  ACCOUNT base;
  // String path = "m/84'/3324'/0'";
  int lastSyncTimestamp;
  String accountId;

  void init(String id, ACCOUNT base, {int interval});
  Future start();
  void stop();
  // Decimal toCoinUnit(Decimal smallUnit);
  // Decimal toSmallUnit(Decimal coinUnit);
  // Decimal calculateFastFee();
  // Decimal calculateStandardFee();
  // Decimal calculateSlowFee();

  Future<List> getReceivingAddress(String currencyId);
  Future<List> getChangingAddress(String currencyId);
  Future<Map<TransactionPriority, Decimal>> getTransactionFee(
      String blockchainId);
  Future<Decimal> estimateGasLimit(
      String blockchainId, String from, String to, String amount, String data);
  Future<int> getNonce(String blockchainId, String address);
  Future<List<UnspentTxOut>> getUnspentTxOut(String currencyId);

  getTransactions();

  // TODO: Keep or remove
  // prepareTransaction();
  Future<bool> publishTransaction(String blockchainId, Transaction transaction);
}
