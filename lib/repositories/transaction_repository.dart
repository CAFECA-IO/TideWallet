import 'package:rxdart/subjects.dart';
import 'package:decimal/decimal.dart';

import '../cores/account.dart';
import '../models/account.model.dart';
import '../models/transaction.model.dart';

class TransactionRepository {
  Account? _account;
  Account? _shareAccount;
  Transaction? _transaction;

  PublishSubject<AccountMessage> get listener => AccountCore().messenger;

  TransactionRepository();

  set account(Account account) => this._account = account;
  Account get account => this._account!;

  set shareAccount(Account account) => this._shareAccount = account;
  Account get shareAccount => this._shareAccount!;

  set transaction(Transaction transaction) => this._transaction = transaction;
  Transaction get transaction => this._transaction!;

  Future<Map> getAccountDetail(String accountId) async {
    final Map accountDetail =
        await AccountCore().getAccountDetail(this.account.id);
    Account account = accountDetail["account"];
    Account shareAccount = accountDetail["shareAccount"];
    this.account = account;
    this.shareAccount = shareAccount;

    return accountDetail;
  }

  Future<Map<String, dynamic>> getTransactionDetail(
      String accountId, String txid) async {
    final Map<String, dynamic> transactionDetail =
        await AccountCore().getTransactionDetail(accountId, txid);
    Account account = transactionDetail["account"];
    Account shareAccount = transactionDetail["shareAccount"];
    Transaction transaction = transactionDetail["transaction"];
    this.account = account;
    this.shareAccount = shareAccount;
    this.transaction = transaction;
    return transactionDetail;
  }

  bool verifyAmount(String amount, String fee) =>
      AccountCore().verifyAmount(this.account.id, amount, fee);

  Future<bool> verifyAddress(String address) =>
      AccountCore().verifyAddress(this.account.id, address);

  Future<String> getReceivingAddress() =>
      AccountCore().getReceivingAddress(this.account.id);

  Future<Map> getTransactionFee(
          {String? address,
          String? amount,
          String? message,
          TransactionPriority? priority}) =>
      AccountCore().getTransactionFee(this.account.id,
          to: address, amount: amount, message: message, priority: priority);

  Future sendTransaction(
          {required String thirdPartyId,
          required String to,
          required Decimal amount,
          Decimal? fee,
          Decimal? gasPrice,
          Decimal? gasLimit,
          String? message}) =>
      AccountCore().sendTransaction(this.account.id,
          thirdPartyId: thirdPartyId,
          to: to,
          amount: amount,
          fee: fee,
          gasPrice: gasPrice,
          gasLimit: gasLimit,
          message: message);
}
