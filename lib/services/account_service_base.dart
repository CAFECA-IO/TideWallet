import 'package:decimal/decimal.dart';
import 'package:tidewallet3/models/utxo.model.dart';

import 'account_service.dart';
import '../models/transaction.model.dart';

class AccountServiceBase extends AccountService {
  @override
  Decimal calculateFastFee() {
    // TODO: implement calculateFastFee
    throw UnimplementedError();
  }

  @override
  Decimal calculateSlowFee() {
    // TODO: implement calculateSlowFee
    throw UnimplementedError();
  }

  @override
  Decimal calculateStandardFee() {
    // TODO: implement calculateStandardFee
    throw UnimplementedError();
  }

  @override
  getTransactions() {
    // TODO: implement getTransactions
    throw UnimplementedError();
  }

  @override
  void init() {
    // TODO: implement init
  }

  @override
  prepareTransaction() {
    // TODO: implement prepareTransaction
    throw UnimplementedError();
  }

  @override
  void start() {
    // TODO: implement start
  }

  @override
  void stop() {
    // TODO: implement stop
  }

  @override
  Decimal toCoinUnit(Decimal smallUnit) {
    // TODO: implement toCoinUnit
    throw UnimplementedError();
  }

  @override
  Decimal toSmallUnit(Decimal coinUnit) {
    // TODO: implement toSmallUnit
    throw UnimplementedError();
  }

  @override
  Future<void> publishTransaction(
      String blockchainId, String currencyId, Transaction transaction) {
    // TODO: implement publishTransaction
    throw UnimplementedError();
  }

  @override
  Future<Map<TransactionPriority, Decimal>> getTransactionFee() async {
    // TODO: implement publishTransaction
    throw UnimplementedError();
  }

  @override
  Future<String> getChangingAddress(String currencyId) async {
    // TODO: implement publishTransaction
    throw UnimplementedError();
  }

  @override
  Future<String> getReceivingAddress(String currencyId) async {
    // TODO: implement publishTransaction
    throw UnimplementedError();
  }

  @override
  Future<Decimal> estimateGasLimit(String hex) {
    // TODO: implement estimateGasLimit
    throw UnimplementedError();
  }

  @override
  Future<List<UnspentTxOut>> getUnspentTxOut(String currencyId) {
    // TODO: implement getUnspentTxOut
    throw UnimplementedError();
  }

  @override
  Future<int> getNonce() {
    // TODO: implement getNon
    throw UnimplementedError();
  }
}
