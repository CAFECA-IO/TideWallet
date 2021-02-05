import 'package:rxdart/rxdart.dart';

import '../constants/account_config.dart';
import '../constants/endpoint.dart';
import '../models/account.model.dart';
import '../models/api_response.mode.dart';
import '../services/account_service.dart';
import '../services/account_service_base.dart';
import '../services/ethereum_service.dart';
import '../database/entity/account.dart' as AccountEntity;
import '../database/db_operator.dart';
import '../helpers/logger.dart';
import '../helpers/http_agent.dart';

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
    APIResponse res =
        await HTTPAgent().get(Endpoint.SUSANOO + '/wallet/accounts');

    List accounts = res.data;
    List<AccountEntity.Account> result = await DBOperator().accountDao.findAllAccounts();

    Log.debug(result);
    // TODO: Get amount in DB
    for (var i = 0; i < accounts.length; i++) {
      final String id = accounts[i]['account_id'];
      bool exist = result.indexWhere((el) => el.accountId == id) > -1;


      AccountEntity.Account acc = AccountEntity.Account(
          accountId: id, userId: 'eee');


      // Currency _currency = Currency.fromMap(ACCOUNT_LIST[value]);

      // this.currencies[value] = [];
      // this.currencies[value].add(_currency);

      // if (value == ACCOUNT.ETH) {
      //   AccountService ethService = EthereumService(_service);
      //   this._services.add(ethService);
      //   ethService.start();
      // }
      if (!exist) {
        await createAccount(acc);

      }

      // this.messenger.add(AccountMessage(
      //     evt: ACCOUNT_EVT.OnUpdateAccount,
      //     value: _currency));
    }
  }

  close() {
    messenger.close();
  }

  Future<bool> checkAccountExist() async {
    await Future.delayed(Duration(milliseconds: 300));

    return false;
  }

  createAccount(AccountEntity.Account account) async {
    await DBOperator().accountDao.insertAccount(account);
  }

  AccountService getService(ACCOUNT type) {
    return _services.firstWhere((svc) => (svc.base == type));
  }

  // Future<String> getReceivingAddress(Currency curr) async {
  //   return await this._services.getReceivingAddress();
  // }

  List<Currency> getCurrencies(ACCOUNT type) => this.currencies[type];
}
