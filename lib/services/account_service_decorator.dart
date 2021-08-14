import './account_service.dart';

abstract class AccountServiceDecorator extends AccountService {
  final AccountService service;
  String get accountId => this.service.shareAccountId!;

  AccountServiceDecorator(this.service);
}
