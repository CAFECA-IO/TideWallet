import 'package:rxdart/subjects.dart';
import 'package:decimal/decimal.dart';

import '../services/account_service.dart';
import '../cores/account.dart';
import '../models/account.model.dart';
import '../models/transaction.model.dart';
import '../services/transaction_service.dart';
import '../services/transaction_service_based.dart';
import '../services/transaction_service_bitcoin.dart';
import '../services/transaction_service_ethereum.dart';
import '../constants/account_config.dart';

class TransactionRepository {
  Currency _currency;
  AccountService _accountService;
  TransactionService _transactionService;
  PublishSubject<AccountMessage> get listener => AccountCore().messenger;

  TransactionRepository();

  void setCurrency(Currency currency) {
    this._currency = currency;
    _accountService = AccountCore().getService(this._currency.accountType);

    switch (this._currency.accountType) {
      case ACCOUNT.BTC:
        _transactionService =
            BitcoinTransactionService(TransactionServiceBased());
        break;
      case ACCOUNT.ETH:
        _transactionService =
            EthereumTransactionService(TransactionServiceBased());
        break;
      case ACCOUNT.XRP:
        // TODO: Handle this case.
        break;
    }
  }

  get currency => this._currency;

  // bool validAddress(String address) {
  //   return address.length < 8 ? false : true;
  // }

  bool validAmount(String amount,
      {TransactionPriority priority, String gasLimit, String gasPrice}) {
    return amount.length > 4 ? false : true;
  }

  // Future<Map<TransactionPriority, String>> fetchGasPrice() async {
  //   await Future.delayed(Duration(seconds: 1));
  //   return {
  //     TransactionPriority.slow: "33.46200020",
  //     TransactionPriority.standard: "43.20000233",
  //     TransactionPriority.fast: "56.82152409"
  //   };
  // }

  // Future<String> fetchGasLimit() async {
  //   await Future.delayed(Duration(seconds: 1));
  //   return '25148';
  // }

  Future<bool> createTransaction(List<dynamic> condition) async {
    // create
    // sign
    // publish
    await Future.delayed(Duration(seconds: 5));
    return true;
  }

  Future<List<Transaction>> getTransactions() async {
    return await _accountService.getTransactions();
  }

  Future<String> getReceivingAddress() async {
    return await _accountService.getReceivingAddress();
  }

  Future<List<dynamic>> getTransactionFee(String hex) async {
    return await _accountService.getTransactionFee(hex);
  }

  Future<bool> verifyAddress(String address, bool publish) async {
    bool verified = false;
    String _address = await _accountService.getChangingAddress();
    verified = address != _address;
    if (verified) {
      verified = _transactionService.verifyAddress(address, publish);
    }
    return verified;
  }
}
