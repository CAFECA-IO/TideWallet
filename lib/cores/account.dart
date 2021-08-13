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
import '../database/entity/user.dart';
import '../database/entity/currency.dart';
import '../helpers/http_agent.dart';
import '../helpers/logger.dart';

class AccountCore {
  static int syncInteral = 24 * 60 * 60 * 1000; // milliseconds
  // ignore: close_sinks
  late PublishSubject<AccountMessage> messenger;
  bool _isInit = false;
  bool _debugMode = false;
  List<AccountService> _services = [];
  Map<String, List<Account>> _accounts = {};
  List<DisplayCurrency> settingOptions = [];

  Map<String, List<Account>> get accounts {
    return _accounts;
  }

  List<Account>? getAccountsByShareAccounttId(String shareAccountId) =>
      this._accounts[shareAccountId];

  List<Account> getAllAccounts() =>
      this._accounts.values.reduce((currList, currs) => currList + currs);

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

  Future _getSupportedToken(List<NetworkEntity> chains, bool update) async {
    for (NetworkEntity chain in chains) {
      List<CurrencyEntity> tokens = await DBOperator()
          .currencyDao
          .findAllTokensByBlockchainId(chain.blockchainId);

      if (tokens.isEmpty || update) {
        APIResponse res = await HTTPAgent().get(Endpoint.url +
            '/blockchain/${chain.blockchainId}/token?type=TideWallet');

        if (res.data != null) {
          List data = res.data;
          tokens = [];
          for (var d in data) {
            tokens.add(CurrencyEntity.fromJson(d));
          }
          await DBOperator().currencyDao.insertCurrencies(tokens);
        }
      }
      List<DisplayCurrency> dcs = [];
      for (CurrencyEntity t in tokens) {
        dcs.add(DisplayCurrency.fromCurrencyEntity(t));
      }
      this.settingOptions.addAll(dcs);
    }
  }

  Future init({required bool debugMode}) async {
    this._isInit = true;
    this._debugMode = debugMode;
    await _initAccounts();
  }

  _initAccounts() async {
    Log.debug('_initAccounts this._debugMode: ${this._debugMode}');
    UserEntity user = (await DBOperator().userDao.findUser())!;
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    final bool update = user.lastSyncTime - timestamp > AccountCore.syncInteral;
    final chains = (await this.getNetworks(update))
        .where((network) => this._debugMode ? true : network.publish)
        .toList();
    final accounts = await this.getAccounts(update);
    await this.getSupportedCurrencies(update);

    if (update) {
      final updateUser = user.copyWith(lastSyncTime: timestamp);
      await DBOperator().userDao.insertUser(updateUser);
    }

    for (var i = 0; i < accounts.length; i++) {
      if (accounts[i].id != accounts[i].shareAccountId) continue;
      AccountService? svc;
      int blockIndex = chains.indexWhere(
          (chain) => chain.blockchainId == accounts[i].blockchainId);

      if (blockIndex > -1) {
        int srvIndex = this._services.indexWhere(
            (svc) => svc.shareAccountId == accounts[i].shareAccountId);
        if (srvIndex >= 0) {
          svc = this._services[srvIndex];
          if (this._debugMode) {
            return;
          } else {
            if (!chains[blockIndex].publish) {
              svc.stop();
              this._services.remove(svc);
              this._accounts.remove(accounts[i].shareAccountId);
              return;
            }
          }
        }

        ACCOUNT? base;
        switch (chains[blockIndex].blockchainCoinType) {
          case 0:
          case 1:
            svc = BitcoinService(AccountServiceBase());
            base = ACCOUNT.BTC;
            break;
          case 60:
          case 603:
            svc = EthereumService(AccountServiceBase());
            base = ACCOUNT.ETH;
            break;
          // case 3324:
          case 8017:
            svc = EthereumService(AccountServiceBase());
            base = ACCOUNT.CFC;
            break;
          default:
        }

        if (svc != null &&
            base != null &&
            this._accounts[accounts[i].shareAccountId] == null) {
          this._accounts[accounts[i].shareAccountId] = [];

          this._services.add(svc);
          svc.init(accounts[i].shareAccountId, base);
          await svc.start();
        }
      }
    }
    await this._getSupportedToken(chains, update);
  }

  close() {
    this._isInit = false;
    this._services.forEach((service) {
      service.stop();
    });
    this._services = [];
    this._accounts = {};
    this.settingOptions = [];
  }

  Future<bool> checkAccountExist() async {
    await Future.delayed(Duration(milliseconds: 300));

    return false;
  }

  AccountService getService(String shareAccountId) {
    return _services
        .firstWhere((svc) => (svc.shareAccountId == shareAccountId));
  }

  Future<List<NetworkEntity>> getNetworks(bool update) async {
    List<NetworkEntity> networks =
        await DBOperator().networkDao.findAllNetworks();

    if (networks.isEmpty || update) {
      APIResponse res = await HTTPAgent().get(Endpoint.url + '/blockchain');
      List l = res.data;
      networks = l.map((chain) => NetworkEntity.fromJson(chain)).toList();
      await DBOperator().networkDao.insertNetworks(networks);
    }

    return networks;
  }

  Future<List<AccountEntity>> getAccounts(bool update) async {
    List<AccountEntity> result =
        await DBOperator().accountDao.findAllAccounts();
    if (result.isEmpty || update) {
      result = await this._addAccount(result);
      return result;
    } else {
      return result;
    }
  }

  Future<List<AccountEntity>> _addAccount(List<AccountEntity> local) async {
    APIResponse res = await HTTPAgent().get(Endpoint.url + '/wallet/accounts');

    List l = res.data ?? [];
    UserEntity user = (await DBOperator().userDao.findUser())!;

    for (var d in l) {
      final String id = d['account_id'];
      bool exist = local.indexWhere((el) => el.id == id) > -1;

      if (!exist) {
        AccountEntity acc = AccountEntity.fromAccountJson(d, id, user.userId);
        await DBOperator().accountDao.insertAccount(acc);
        local.add(acc);
      }
    }
    return local;
  }

  Future<List<CurrencyEntity>> getSupportedCurrencies(bool update) async {
    List<CurrencyEntity> local =
        await DBOperator().currencyDao.findAllCurrencies();
    List<CurrencyEntity> updateCurrencies = [];
    if (local.isEmpty || update) {
      updateCurrencies = await _addSupportedCurrencies(local);
    }
    return local + updateCurrencies;
  }

  Future<List<CurrencyEntity>> _addSupportedCurrencies(
      List<CurrencyEntity> local) async {
    APIResponse res = await HTTPAgent().get(Endpoint.url + '/currency');
    List<CurrencyEntity> l = [];
    if (res.data != null) {
      for (dynamic d in res.data) {
        if (local.indexWhere((c) => c.currencyId == d['currency_id']) > -1)
          continue;
        else {
          l.add(CurrencyEntity.fromJson(d));
        }
      }
      await DBOperator().currencyDao.insertCurrencies(l);
      return l;
    }
    return [];
  }

  // Future<String> getReceivingAddress(Currency curr) async {
  //   return await this._services.getReceivingAddress();
  // }

}
