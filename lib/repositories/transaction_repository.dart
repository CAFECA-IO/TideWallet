import 'package:rxdart/subjects.dart';
import 'package:decimal/decimal.dart';

import '../cores/account.dart';
import '../models/account.model.dart';
import '../models/transaction.model.dart';

class TransactionRepository {
  Account? _account;

  PublishSubject<AccountMessage> get listener => AccountCore().messenger;

  TransactionRepository();

  set account(Account account) => this._account = account;
  Account get account => this._account!;

  bool verifyAmount(String amount, String fee) =>
      AccountCore().verifyAmount(this.account.id, amount, fee);

  Future<bool> verifyAddress(String address) =>
      AccountCore().verifyAddress(this.account.id, address);

  Future<Map> getAccountDetail() =>
      AccountCore().getAccountDetail(this.account.id);

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
