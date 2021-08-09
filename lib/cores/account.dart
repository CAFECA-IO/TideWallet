import 'package:rxdart/rxdart.dart';

import '../constants/account_config.dart';
import '../constants/endpoint.dart';
import '../models/account.model.dart';
import '../models/api_response.mode.dart';
import '../services/account_service.dart';
import '../services/account_service_base.dart';
import '../services/bitcoin_service.dart';
import '../services/ethereum_service.dart';
import '../database/entity/account.dart';
import '../database/entity/network.dart';
import '../database/db_operator.dart';
import '../database/entity/currency.dart';
import '../helpers/http_agent.dart';
import '../helpers/logger.dart';

class AccountCore {
  // ignore: close_sinks
  PublishSubject<AccountMessage> messenger;
  bool _isInit = false;
  bool _debugMode = false;
  List<AccountService> _services = [];
  List<Currency> accounts = [];
  Map<String, List<Currency>> _currencies = {};
  List<DisplayCurrency> settingOptions = [];

  Map<String, List<Currency>> get currencies {
    return _currencies;
  }

  static final AccountCore _instance = AccountCore._internal();
  factory AccountCore() => _instance;

  AccountCore._internal();

  bool get isInit => _isInit;

  setBitcoinAccountService() {
    this._services.add(BitcoinService(AccountServiceBase()));
  }

  setMessenger() {
    messenger = PublishSubject<AccountMessage>();
  }

  Future init({bool debugMode}) async {
    this._isInit = true;
    this._debugMode = debugMode;
    await _initAccounts();
  }

  _initAccounts() async {
    Log.debug('_initAccounts this._debugMode: ${this._debugMode}');
    final chains = await this.getNetworks();

    final accounts = await this.getAccounts();

    await this.getSupportedCurrencies();

    for (var i = 0; i < accounts.length; i++) {
      int blockIndex = chains
          .indexWhere((chain) => chain.networkId == accounts[i].networkId);

      if (blockIndex > -1) {
        AccountService svc;
        ACCOUNT account;
        switch (chains[blockIndex].coinType) {
          case 0:
          case 1:
            svc = BitcoinService(AccountServiceBase());
            account = ACCOUNT.BTC;
            break;
          case 60:
          case 603:
            svc = EthereumService(AccountServiceBase());
            account = ACCOUNT.ETH;
            break;
          // case 3324:
          case 8017:
            svc = EthereumService(AccountServiceBase());
            account = ACCOUNT.CFC;
            break;
          default:
        }

        if (svc != null && this._currencies[accounts[i].accountId] == null) {
          this._currencies[accounts[i].accountId] = [];

          this._services.add(svc);
          svc.init(accounts[i].accountId, account);
          await svc.start();
        }
      }
    }

    Future.wait(
      [
        _addAccount(accounts),
      ],
    );
  }

  close() {
    this._isInit = false;

    this._services.forEach((service) {
      service.stop();
    });
    this._services = [];
    this.accounts = [];
    this._currencies = {};
    this.settingOptions = [];
  }

  Future<bool> checkAccountExist() async {
    await Future.delayed(Duration(milliseconds: 300));

    return false;
  }

  createAccount(AccountEntity account) async {
    await DBOperator().accountDao.insertAccount(account);
  }

  AccountService getService(String accountId) {
    return _services.firstWhere((svc) => (svc.accountId == accountId));
  }

  Future<List<NetworkEntity>> getNetworks() async {
    List<NetworkEntity> networks =
        await DBOperator().networkDao.findAllNetworks();

    if (networks.isEmpty) {
      APIResponse res = await HTTPAgent().get(Endpoint.url + '/blockchain');
      List l = res.data;

      networks = l.map((chain) => NetworkEntity.fromJson(chain)).toList();

      await DBOperator().networkDao.insertNetworks(networks);
    }

    return networks
        .where((network) => this._debugMode ? true : network.publish)
        .toList();
  }

  Future<List<AccountEntity>> getAccounts() async {
    List<AccountEntity> result =
        await DBOperator().accountDao.findAllAccounts();
    if (result.isEmpty) {
      result = await this._addAccount(result);
      return result;
    } else {
      return result;
    }
  }

  Future<List<AccountEntity>> _addAccount(List<AccountEntity> local) async {
    APIResponse res = await HTTPAgent().get(Endpoint.url + '/wallet/accounts');

    List l = res.data ?? [];
    final user = await DBOperator().userDao.findUser();

    for (var d in l) {
      final String id = d['account_id'];
      bool exist = local.indexWhere((el) => el.accountId == id) > -1;

      if (!exist) {
        AccountEntity acc = AccountEntity(
            accountId: id, userId: user.userId, networkId: d['blockchain_id']);
        await createAccount(acc);
        local.add(acc);
      }
    }
    return local;
  }

  Future getSupportedCurrencies() async {
    final local = await DBOperator().currencyDao.findAllCurrencies();
    if (local.isEmpty) {
      await _addSupportedCurrencies(local);
    }
  }

  Future _addSupportedCurrencies(List<CurrencyEntity> local) async {
    APIResponse res = await HTTPAgent().get(Endpoint.url + '/currency');

    if (res.data != null) {
      List l = res.data;
      l.removeWhere((el) =>
          local.indexWhere((c) => c.currencyId == el['currency_id']) > -1);
      l = l.map((c) => CurrencyEntity.fromJson(c)).toList();
      await DBOperator().currencyDao.insertCurrencies(l);
    }
  }

  // Future<String> getReceivingAddress(Currency curr) async {
  //   return await this._services.getReceivingAddress();
  // }

  List<Currency> getCurrencies(String accountId) => this._currencies[accountId];

  List<Currency> getAllCurrencies() =>
      this._currencies.values.reduce((currList, currs) => currList + currs);
}
