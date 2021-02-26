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

class AccountCore {
  // ignore: close_sinks
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

  // TODO TEST
  setBitcoinAccountService() {
    this._services.add(BitcoinService(AccountServiceBase()));
  }

  init() async {
    //
    _isInit = true;
    await _initAccounts();
  }

  _initAccounts() async {
    final chains = await this.getNetworks(publish: false);
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
          default:
        }

        if (svc != null) {
          this.currencies[account] = [];

          // this.messenger.add(AccountMessage(
          //     evt: ACCOUNT_EVT.OnUpdateAccount,
          //     value: _currency));
          this._services.add(svc);
          svc.init(accounts[i].accountId, account);
          svc.start();
        }
      }
    }

    Future.wait(
      [
        _addAccount(accounts),
        _addSupportedCurrencies(),
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
    this.currencies = {};
  }

  Future<bool> checkAccountExist() async {
    await Future.delayed(Duration(milliseconds: 300));

    return false;
  }

  createAccount(AccountEntity account) async {
    await DBOperator().accountDao.insertAccount(account);
  }

  AccountService getService(ACCOUNT type) {
    return _services.firstWhere((svc) => (svc.base == type));
  }

  Future<List<NetworkEntity>> getNetworks({publish = true}) async {
    List<NetworkEntity> networks =
        await DBOperator().networkDao.findAllNetworks();

    if (networks.isEmpty) {
      APIResponse res = await HTTPAgent().get(Endpoint.SUSANOO + '/blockchain');
      List l = res.data;
      networks = l.map((chain) => NetworkEntity.fromJson(chain)).toList();

      if (publish)
        networks.removeWhere((NetworkEntity n) => !n.publish);
      else
        networks.removeWhere((NetworkEntity n) => n.publish);

      await DBOperator().networkDao.insertNetworks(networks);
    }

    return networks;
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
    APIResponse res =
        await HTTPAgent().get(Endpoint.SUSANOO + '/wallet/accounts');

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
      await _addSupportedCurrencies();
    }
  }

  Future _addSupportedCurrencies() async {
    APIResponse res = await HTTPAgent().get(Endpoint.SUSANOO + '/currency');

    if (res.data != null) {
      List l = res.data;
      l = l.map((c) => CurrencyEntity.fromJson(c)).toList();
      await DBOperator().currencyDao.insertCurrencies(l);
    }
  }

  // Future<String> getReceivingAddress(Currency curr) async {
  //   return await this._services.getReceivingAddress();
  // }

  List<Currency> getCurrencies(ACCOUNT type) => this.currencies[type];
}
