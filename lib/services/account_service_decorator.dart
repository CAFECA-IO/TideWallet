import './account_service.dart';

abstract class AccountServiceDecorator extends AccountService {
  final AccountService service;

  AccountServiceDecorator(this.service);
}
