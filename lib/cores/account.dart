import 'package:decimal/decimal.dart';
import 'package:rxdart/rxdart.dart';

import 'trader.dart';

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
import '../helpers/prefer_manager.dart';

class AccountCore {
  static int syncInteral = 24 * 60 * 60 * 1000; // milliseconds
  static final AccountCore _instance = AccountCore._internal();
  factory AccountCore() {
    return _instance;
  }
  AccountCore._internal();

  PublishSubject<AccountMessage> messenger = PublishSubject<AccountMessage>();
  PrefManager _prefManager = PrefManager();
  bool _isInit = false;
  bool _debugMode = false;
  List<AccountService> _services = [];
  Map<String, List<Account>> _accounts = {};
  Map _preferDisplay = {};
  List<DisplayCurrency> settingOptions = [];

  bool get debugMode => this._debugMode;

  Map<String, List<Account>> get accounts {
    return _accounts;
  }

  Map get preferDisplay => this._preferDisplay;

  Future<Map?> getSeletedDisplay() {
    return this._prefManager.getSeletedDisplay();
  }

  List<Account>? getAccountsByShareAccountId(String shareAccountId) =>
      this._accounts[shareAccountId];

  List<Account> displayFilter(List<Account> accounts) {
    if (this.debugMode)
      return accounts
          .where((acc) =>
              acc.type == 'currency' ||
              (this.preferDisplay[acc.currencyId] != null &&
                  this.preferDisplay[acc.currencyId] == true))
          .toList();
    else
      return accounts
          .where((acc) =>
              (acc.type == 'currency' && acc.publish) ||
              (this.preferDisplay[acc.currencyId] != null &&
                  this.preferDisplay[acc.currencyId] == true))
          .toList();
  }

// ++ need check
  Future<bool> addToken(Account account, Token token) async {
    AccountService _ethService = getService(account.id);

    return (_ethService as EthereumService)
        .addToken(account.blockchainId, token);
  }

  Future toggleDisplay(Account account, bool value) async {
    final result = await this
        ._prefManager
        .setSelectedDisplay(account.shareAccountId, account.currencyId, value);
    this._preferDisplay = result;

    if (value == true) {
      AccountService _service =
          AccountCore().getService(account.shareAccountId);
      _service.synchro(force: true);
    } else {
      AccountMessage msg = AccountMessage(
          evt: ACCOUNT_EVT.ToggleDisplayCurrency, value: account.currencyId);

      AccountCore().messenger.add(msg);
    }

    return this._preferDisplay;
  }

  List<Account> getAllAccounts() {
    List<Account> accounts =
        this._accounts.values.reduce((currList, currs) => currList + currs);
    accounts
      ..sort((a, b) => a.accountType.index.compareTo(b.accountType.index));
    return displayFilter(accounts);
  }

  Future<Map> getOverview() async {
    Fiat fiat = await Trader().getSelectedFiat();
    Decimal totalBalanceInFiat = Decimal.zero;
    for (Account account in this.getAllAccounts()) {
      account.inFiat = Trader().calculateToFiat(account, fiat);
      totalBalanceInFiat += account.inFiat!;
    }

    return {
      "account": this.getAllAccounts(),
      "fiat": fiat,
      'totalBalanceInFiat': totalBalanceInFiat
    };
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

  Future init({bool? debugMode}) async {
    if (debugMode != null && debugMode != this._debugMode) {
      this._debugMode = debugMode;
      this._prefManager.setDebugMode(debugMode);
      this._isInit = false;
    }
    if (!this._isInit) {
      await _initAccounts();
    }
  }

  _initAccounts() async {
    this._isInit = true;
    UserEntity user = (await DBOperator().userDao.findUser())!;
    final int timestamp = DateTime.now().millisecondsSinceEpoch;

    final bool update = user.lastSyncTime == null
        ? true
        : user.lastSyncTime! - timestamp > AccountCore.syncInteral;

    await this.getSupportedCurrencies(update);

    final networks = (await this.getNetworks(update))
        .where((network) => this._debugMode ? true : network.publish)
        .toList();

    final accounts = await this.getAccounts(update);

    if (update) {
      final updateUser = user.copyWith(lastSyncTime: timestamp);
      await DBOperator().userDao.insertUser(updateUser);
    }

    for (var i = 0; i < accounts.length; i++) {
      if (accounts[i].id != accounts[i].shareAccountId) continue;
      AccountService? svc;
      int blockIndex = networks.indexWhere(
          (chain) => chain.blockchainId == accounts[i].blockchainId);

      if (blockIndex > -1) {
        int srvIndex = this._services.indexWhere(
            (svc) => svc.shareAccountId == accounts[i].shareAccountId);
        if (srvIndex >= 0) {
          svc = this._services[srvIndex];
          if (this._debugMode) {
            return;
          } else {
            if (!networks[blockIndex].publish) {
              svc.stop();
              this._services.remove(svc);
              this._accounts.remove(accounts[i].shareAccountId);
              return;
            }
          }
        }

        ACCOUNT? base;
        switch (networks[blockIndex].blockchainCoinType) {
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
    await this._getSupportedToken(networks, update);
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
      Log.debug("getNetworks networks: $l");
      networks = l.map((chain) => NetworkEntity.fromJson(chain)).toList();
      await DBOperator().networkDao.insertNetworks(networks);
    }
    return networks;
  }

  Future<List<AccountEntity>> getAccounts(bool update) async {
    List<AccountEntity> result =
        await DBOperator().accountDao.findAllAccounts();
    if (result.isEmpty || update) {
      result = await this._addAccount();
      return result;
    } else {
      return result;
    }
  }

  Future<List<AccountEntity>> _addAccount() async {
    APIResponse res = await HTTPAgent().get(Endpoint.url + '/wallet/accounts');

    List l = res.data ?? [];
    List<AccountEntity> accs = [];

    UserEntity user = (await DBOperator().userDao.findUser())!;
    Log.debug('_addAccount user.userId: ${user.userId}');

    for (var d in l) {
      final String id = d['account_id'];
      Log.debug('_addAccount AccountData: $d');
      AccountEntity acc = AccountEntity.fromAccountJson(d, id, user.userId);
      await DBOperator().accountDao.insertAccount(acc);
      Log.debug(
          '_addAccount AccountEntity, id: ${acc.id}, blockchainId: ${acc.blockchainId}, currencyId: ${acc.currencyId}, balance: ${acc.balance}');

      accs.add(acc);
    }
    return accs;
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
