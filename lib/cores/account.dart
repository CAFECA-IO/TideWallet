import 'package:rxdart/rxdart.dart';

import '../constants/account_config.dart';
import '../models/account.model.dart';
import '../services/account_service.dart';

class AccountCore {
  PublishSubject<AccountMessage> messenger;
  bool _isInit = false;
  List<AccountService> _services;
  List<Account> accounts = [];
  Map<ACCOUNT, List<Account>> tokens;

  static final AccountCore _instance = AccountCore._internal();
  factory AccountCore() => _instance;

  AccountCore._internal();

  bool get isInit => _isInit;
  
  setMessenger() {
    messenger = PublishSubject<AccountMessage>();
  }

  init() async {
    // 
    _isInit = true;
    await _initAccounts();
  }

  _initAccounts() async {
    // TODO: Get amount in DB
    for (var value in ACCOUNT.values) {
      print('$value: ${ACCOUNT_LIST[value]}');
      print(this.messenger);
      if (ACCOUNT_LIST[value] != null) {
        this.messenger.add(AccountMessage(evt: ACCOUNT_EVT.OnUpdateAccount, value: Account.fromMap(ACCOUNT_LIST[value])));
      }
    }

  }


  close() {
    messenger.close();
  }
}
