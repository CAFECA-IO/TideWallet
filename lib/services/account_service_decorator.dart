import '../models/transaction.model.dart';

import './account_service.dart';

abstract class AccountServiceDecorator extends AccountService {
  final AccountService service;
  String get shareAccountId => this.service.shareAccountId!;

  AccountServiceDecorator(this.service);

  Future<List<Transaction>> getTrasnctions(String id) =>
      this.service.getTrasnctions(id);

  Future<Transaction> getTransactionDetail(String txid) =>
      this.service.getTransactionDetail(txid);
}
