import 'package:rxdart/rxdart.dart';
import 'package:tidewallet3/mock/endpoint.dart';

import '../constants/account_config.dart';
import '../models/account.model.dart';
import '../services/account_service.dart';

class AccountCore {
  PublishSubject<AccountMessage> messenger;
  bool _isInit = false;
  List<AccountService> _services;
  List<Currency> accounts = [];
  Map<ACCOUNT, List<Currency>> tokens = {};

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
      if (ACCOUNT_LIST[value] != null) {
        Currency _currency = Currency.fromMap(ACCOUNT_LIST[value]);
        tokens[value] = [];
        tokens[value].add(_currency);
        this.messenger.add(AccountMessage(evt: ACCOUNT_EVT.OnUpdateAccount, value: _currency));
      }

      // if (value == ACCOUNT.ETH) {
      //   List<Map> result = await getETHTokens();
      //   List<Currency> tokenList = result.map((e) => Currency.fromMap(e)).toList();
      //   tokens[value] = tokens[value].sublist(0, 1) + tokenList;
      // }
    }
  }


  close() {
    messenger.close();
  }
}
