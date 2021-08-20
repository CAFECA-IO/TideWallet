import 'package:rxdart/subjects.dart';
import 'package:decimal/decimal.dart';

import '../cores/account.dart';
import '../models/account.model.dart';
import '../models/transaction.model.dart';

class TransactionRepository {
  PublishSubject<AccountMessage> get listener => AccountCore().messenger;

  TransactionRepository();

  Future<Map<String, dynamic>> getTransactionDetail(
          String accountId, String txid) =>
      AccountCore().getTransactionDetail(accountId, txid);

  bool verifyAmount(String id, String amount, String fee) =>
      AccountCore().verifyAmount(id, amount, fee);

  Future<bool> verifyAddress(String id, String address) =>
      AccountCore().verifyAddress(id, address);

  Future<String> getReceivingAddress(
    String id,
  ) =>
      AccountCore().getReceivingAddress(id);

  Future<Map> getTransactionFee(String id,
          {String? address,
          String? amount,
          String? message,
          TransactionPriority? priority}) =>
      AccountCore().getTransactionFee(id,
          to: address, amount: amount, message: message, priority: priority);

  Future sendTransaction(String id,
          {required String thirdPartyId,
          required String to,
          required Decimal amount,
          Decimal? fee,
          Decimal? gasPrice,
          Decimal? gasLimit,
          String? message}) =>
      AccountCore().sendTransaction(id,
          thirdPartyId: thirdPartyId,
          to: to,
          amount: amount,
          fee: fee,
          gasPrice: gasPrice,
          gasLimit: gasLimit,
          message: message);
}
