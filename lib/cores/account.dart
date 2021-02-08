import 'package:rxdart/rxdart.dart';

import '../constants/account_config.dart';
import '../constants/endpoint.dart';
import '../models/account.model.dart';
import '../models/api_response.mode.dart';
import '../services/account_service.dart';
import '../services/account_service_base.dart';
import '../services/bitcoin_service.dart';
import '../services/ethereum_service.dart';
import '../database/entity/account.dart' as AccountEntity;
import '../database/entity/network.dart' as NetworkEntity;
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
    AccountService service = AccountServiceBase();

    final chains = await this.getNetworks();
    final accounts = await this.getAccounts();

    for (var i = 0; i < accounts.length; i++) {
      int blockIndex = chains.indexWhere(
          (chain) => chain.networkId == accounts[i].networkId);

      if (blockIndex > -1) {
        AccountService svc;
        ACCOUNT account; 
        switch (chains[blockIndex].coinType) {
          case 0:
            svc = BitcoinService(service);
            account = ACCOUNT.BTC;
            break;
          case 60:
            svc = EthereumService(service);
            account = ACCOUNT.ETH;
            break;
          default:
        }

        if (svc != null) {
          Currency _currency = Currency.fromMap(ACCOUNT_LIST[account]);

          this.currencies[account] = [];
          this.currencies[account].add(_currency);

      // this.messenger.add(AccountMessage(
      //     evt: ACCOUNT_EVT.OnUpdateAccount,
      //     value: _currency));
          this._services.add(svc);
          svc.start();
        }
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

  createAccount(AccountEntity.Account account) async {
    await DBOperator().accountDao.insertAccount(account);
  }

  AccountService getService(ACCOUNT type) {
    return _services.firstWhere((svc) => (svc.base == type));
  }

  Future<List<NetworkEntity.Network>> getNetworks({publish = true}) async {
    List<NetworkEntity.Network> networks =
        await DBOperator().networkDao.findAllNetworks();

    if (networks.isEmpty) {
      APIResponse res = await HTTPAgent().get(Endpoint.SUSANOO + '/blockchain');
      List l = res.data;
      networks =
          l.map((chain) => NetworkEntity.Network.fromJson(chain)).toList();
    }

    if (publish) {
      networks.remove((NetworkEntity.Network n) => n.type != 1);
    }

    return networks;
  }

  Future<List<AccountEntity.Account>> getAccounts() async {
    List<AccountEntity.Account> result =
        await DBOperator().accountDao.findAllAccounts();
    APIResponse res =
        await HTTPAgent().get(Endpoint.SUSANOO + '/wallet/accounts');

    List l = res.data ?? [];

    for (var d in l) {
      final String id = d['account_id'];
      bool exist = result.indexWhere((el) => el.accountId == id) > -1;

      if (!exist) {
        AccountEntity.Account acc =
            AccountEntity.Account(accountId: id, userId: 'eee', networkId: d['blockchain_id']);
        await createAccount(acc);
        result.add(acc);
      }
    }

    return result;
  }

  // Future<String> getReceivingAddress(Currency curr) async {
  //   return await this._services.getReceivingAddress();
  // }

  List<Currency> getCurrencies(ACCOUNT type) => this.currencies[type];
}
