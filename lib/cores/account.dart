import 'package:decimal/decimal.dart';
import 'package:rxdart/rxdart.dart';

import '../constants/account_config.dart';
import '../models/account.model.dart';
import '../services/account_service.dart';
import '../services/account_service_base.dart';
import '../services/ethereum_service.dart';

class AccountCore {
  PublishSubject<AccountMessage> messenger;
  bool _isInit = false;
  List<AccountService> _services = [];
  List<Currency> accounts = [];
  Map<ACCOUNT, List<Currency>> currencies = {};

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
    AccountService _service = AccountServiceBase();
    // TODO: Get amount in DB
    for (var value in ACCOUNT.values) {
      if (ACCOUNT_LIST[value] != null) {
        bool exist = await this.checkAccountExist();

        Currency _currency = Currency.fromMap(ACCOUNT_LIST[value]);

        this.currencies[value] = [];
        this.currencies[value].add(_currency);

        if (value == ACCOUNT.ETH) {
          AccountService ethService = EthereumService(_service);
          this._services.add(ethService);
          ethService.start();
        }

        await createAccount();

        this.messenger.add(AccountMessage(
            evt: ACCOUNT_EVT.OnUpdateAccount,
            value: _currency));
      }
    }
  }

  close() {
    messenger.close();
  }






  Future<bool> checkAccountExist() async {
    await Future.delayed(Duration(milliseconds: 300));

    return false;
  }

  createAccount() async {
    await Future.delayed(Duration(milliseconds: 300));
  }

  AccountService getService(ACCOUNT type) {
    return _services.firstWhere((svc) => (svc.base == type));
  }

  // Future<String> getReceivingAddress(Currency curr) async {
  //   return await this._services.getReceivingAddress();
  // }

  List<Currency> getCurrencies(ACCOUNT type) => this.currencies[type];

}
