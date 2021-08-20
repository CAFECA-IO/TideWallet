import 'package:decimal/decimal.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tidewallet3/database/entity/transaction.dart';

import '../constants/account_config.dart';
import '../constants/endpoint.dart';
import '../models/account.model.dart';
import '../models/transaction.model.dart';
import '../models/api_response.mode.dart';
import '../models/utxo.model.dart';
import '../services/account_service.dart';
import '../services/account_service_base.dart';
import '../services/bitcoin_service.dart';
import '../services/ethereum_service.dart';
import '../services/transaction_service.dart';
import '../services/transaction_service_based.dart';
import '../services/transaction_service_bitcoin.dart';
import '../services/transaction_service_ethereum.dart';
import '../database/entity/account.dart';
import '../database/entity/network.dart';
import '../database/db_operator.dart';
import '../database/entity/user.dart';
import '../database/entity/currency.dart';
import '../helpers/converter.dart';
import '../helpers/http_agent.dart';
import '../helpers/logger.dart';
import '../helpers/prefer_manager.dart';

class AccountCore {
  static int syncInteral = 24 * 60 * 60 * 1000; // milliseconds
  static final AccountCore _instance = AccountCore._internal();
  factory AccountCore() {
    return _instance;
  }

  late PublishSubject<AccountMessage> _messenger;

  AccountCore._internal() {
    this.setMessenger();
  }

  setMessenger() {
    _messenger = PublishSubject<AccountMessage>();
  }

  PublishSubject<AccountMessage> get messenger => this._messenger;

  bool _isInit = false;
  bool _debugMode = false;
  PrefManager _prefManager = PrefManager();
  List<AccountService> _services = [];
  Map<String, List<Account>> _accounts = {};
  List<DisplayToken> _displayTokens = [];
  Map _preferDisplayToken = {};

  bool get isInit => this._isInit;
  bool get debugMode => this._debugMode;
  Map get preferDisplayToken => this._preferDisplayToken;
  Map<String, List<Account>> get accounts => this._accounts;

  AccountService _getService(String shareAccountId) {
    Log.debug('_getService shareAccountId: $shareAccountId');

    for (AccountService svc in this._services) {
      Log.debug('_getService svc.shareAccountId: ${svc.shareAccountId}');
      Log.debug('_getService svc.base: ${svc.base}');
    }
    return _services
        .firstWhere((svc) => (svc.shareAccountId == shareAccountId));
  }

  Future<List<NetworkEntity>> _getNetworks(bool update) async {
    List<NetworkEntity> networks =
        await DBOperator().networkDao.findAllNetworks();

    if (networks.isEmpty || update) {
      APIResponse res = await HTTPAgent().get(Endpoint.url + '/blockchain');
      List l = res.data;
      Log.debug("_getNetworks networks: $l");
      networks = l.map((chain) => NetworkEntity.fromJson(chain)).toList();
      await DBOperator().networkDao.insertNetworks(networks);
    }
    return networks;
  }

  Future<List<AccountEntity>> _getAccounts(bool update) async {
    List<AccountEntity> result =
        await DBOperator().accountDao.findAllAccounts();
    Log.debug('_addAccount DBResult: $result');

    if (result.isEmpty || update) {
      APIResponse res =
          await HTTPAgent().get(Endpoint.url + '/wallet/accounts');

      List l = res.data ?? [];
      List<AccountEntity> accs = [];

      UserEntity user = (await DBOperator().userDao.findUser())!;

      for (var d in l) {
        final String id = d['account_id'];
        Log.debug('_addAccount AccountData: $d');
        AccountEntity acc = AccountEntity.fromAccountJson(d, id, user.userId);
        await DBOperator().accountDao.insertAccount(acc);
        accs.add(acc);
      }
      return accs;
    } else {
      return result;
    }
  }

  Future _getSupportedCurrencies(bool update) async {
    List<CurrencyEntity> local =
        await DBOperator().currencyDao.findAllCurrencies();
    if (local.isEmpty || update) {
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
      }
    }
  }

  Future _getSupportedToken(String blockchainId, bool update) async {
    List<CurrencyEntity> tokens = await DBOperator()
        .currencyDao
        .findAllTokensByBlockchainId(blockchainId);

    if (tokens.isEmpty || update) {
      APIResponse res = await HTTPAgent().get(
          Endpoint.url + '/blockchain/$blockchainId/token?type=TideWallet');

      if (res.data != null) {
        List data = res.data;
        tokens = [];
        for (var d in data) {
          CurrencyEntity currencyEntity =
              CurrencyEntity.fromJson(d).copyWith(blockchainId: blockchainId);
          tokens.add(currencyEntity);
        }
        await DBOperator().currencyDao.insertCurrencies(tokens);
      }
    }
    List<DisplayToken> dcs = [];
    for (CurrencyEntity t in tokens) {
      dcs.add(DisplayToken.fromCurrencyEntity(t));
    }
    this._displayTokens.addAll(dcs);
  }

  startAccountService() async {
    this.close();
    final UserEntity user = (await DBOperator().userDao.findUser())!;
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    final bool update = user.lastSyncTime == null
        ? true
        : user.lastSyncTime! - timestamp > AccountCore.syncInteral;
    await this._getSupportedCurrencies(update);
    await this._getNetworks(update);
    await this._getAccounts(update);

    if (update) {
      this._displayTokens = [];
      final updateUser = user.copyWith(lastSyncTime: timestamp);
      await DBOperator().userDao.insertUser(updateUser);
    }
    List<AccountEntity> accountEntities =
        await DBOperator().accountDao.findAllAccounts();
    Log.debug('accountEntities: $accountEntities');
    List<Account> accounts =
        (await DBOperator().accountDao.findAllJoinedAccount())
            .map((entity) => Account.fromJoinAccount(entity))
            .toList();
    Log.debug('accounts: $accounts');

    for (Account account in accounts) {
      await _getSupportedToken(account.blockchainId, update);
      Log.debug(
          'account.symbol: ${account.symbol}, account.blockchainCoinType: ${account.blockchainCoinType}, account.id: ${account.id}');
      Log.verbose('account.type: ${account.type}');
      if (account.type != "currency") continue;
      // if (!this.debugMode && !account.chainPublish) continue;
      late AccountService service;

      Log.verbose('account.blockchainCoinType: ${account.blockchainCoinType}');
      switch (account.blockchainCoinType) {
        case 0:
        case 1:
        case 145:
          service = BitcoinService(AccountServiceBase());
          account.accountType = ACCOUNT.BTC;
          break;
        case 60:
        case 603:
          service = EthereumService(AccountServiceBase());
          account.accountType = ACCOUNT.ETH;
          break;
        // case 3324:
        case 8017:
          service = EthereumService(AccountServiceBase());
          account.accountType = ACCOUNT.CFC;
          break;
        default:
          continue;
      }
      Log.verbose('service: $service');
      Log.verbose(' account.accountType: ${account.accountType}');
      this._services.add(service);
      service.init(account.shareAccountId, account.accountType);
      await service.start();
    }

    this._isInit = true;
  }

  _initAccounts() async {
    this._isInit = true;
    UserEntity user = (await DBOperator().userDao.findUser())!;
    final int timestamp = DateTime.now().millisecondsSinceEpoch;

    final bool update = user.lastSyncTime == null
        ? true
        : user.lastSyncTime! - timestamp > AccountCore.syncInteral;

    await this._getSupportedCurrencies(update);

    final networks = (await this._getNetworks(update))
        .where((network) => this._debugMode ? true : network.chainPublish)
        .toList();

    final accounts = await this._getAccounts(update);

    if (update) {
      this._displayTokens = [];
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
            if (!networks[blockIndex].chainPublish) {
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
          await this._getSupportedToken(accounts[i].blockchainId, update);
        }
      }
    }
  }

  close() {
    this._isInit = false;
    this._services.forEach((service) {
      service.stop();
    });
    this._services = [];
    this._accounts = {};
    this._displayTokens = [];
  }

  Future init({bool? debugMode}) async {
    if (debugMode != null && debugMode != this._debugMode) {
      this._debugMode = debugMode;
      this._prefManager.setDebugMode(debugMode);
      this._isInit = false;
    }
    if (!this._isInit) {
      await this.startAccountService();
    }
  }

// TODO
  Future sync() async {}

// TODO
  Future partialSync(String shareAccountId) async {}

  List<Account> displayFilter(List<Account> accounts) {
    if (this.debugMode)
      return accounts
          .where((acc) =>
              acc.type == 'currency' ||
              this.preferDisplayToken[acc.currencyId] == true)
          .toList();
    else
      return accounts
          .where((acc) =>
              (acc.type == 'currency' && acc.currencyPublish) ||
              (this.preferDisplayToken[acc.currencyId] == null ||
                  this.preferDisplayToken[acc.currencyId] == true))
          .toList();
  }

  List<Account> get accountList =>
      this._accounts.values.reduce((currList, currs) => currList + currs);

  List<Account> getSortedAccountList() {
    List<Account> accounts = this.accountList;

    accounts
      ..sort((a, b) => a.accountType.index.compareTo(b.accountType.index));
    return displayFilter(accounts);
    return accounts;
  }

  // Future<Fiat> getSelectedFiat() => Trader().getSelectedFiat();
  String getUserBalance() {
    Decimal totalBalanceInFiat = Decimal.zero;
    for (Account account in this.accountList) {
      totalBalanceInFiat += account.inFiat;
    }
    return totalBalanceInFiat.toString();
  }

  Map getOverview() {
    // Fiat fiat = await getSelectedFiat();
    return {
      "accounts": this.getSortedAccountList(),
      'totalBalanceInFiat': this.getUserBalance()
      // "fiat": fiat,
    };
  }

  Future<List<DisplayToken>> getDisplayTokens() async {
    final selected = await this._prefManager.getSeletedDisplayToken();
    if (selected != null) {
      _displayTokens = _displayTokens.map((opt) {
        if (selected[opt.currencyId] == true) {
          return opt.copyWith(opened: true);
        } else {
          return opt;
        }
      }).toList();
    }
    return _displayTokens;
  }

  Future toggleDisplayToken(DisplayToken token) async {
    Account account = this
        .accountList
        .where((acc) => acc.blockchainId == token.blockchainId)
        .first;

    final result = await this._prefManager.setSelectedDisplay(
        account.shareAccountId, token.currencyId, token.opened);
    this._preferDisplayToken = result;

    EthereumService _service =
        AccountCore()._getService(account.shareAccountId) as EthereumService;

    if (token.opened) {
      await _service.addToken(token);
    }
    _service.synchro(force: true);
  }

/**
 * return Map
 * Account
 * Transactions
 */
  Future<Map<String, dynamic>> getAccountDetail(String id) async {
    Account account = this.accountList.where((acc) => acc.id == id).first;
    late Account shareAccount;
    if (account.type == 'token')
      shareAccount = this._accounts[account.shareAccountId]![0];
    else
      shareAccount = account;
    AccountService service = _getService(account.shareAccountId);
    List<Transaction> transactions = await service.getTrasnctions(id);
    return {
      "account": account,
      "shareAccount": shareAccount,
      "transactions": transactions
    };
  }

  Future<Map<String, dynamic>> getTransactionDetail(
      String id, String txid) async {
    Account account = this.accountList.where((acc) => acc.id == id).first;
    late Account shareAccount;
    if (account.type == 'token')
      shareAccount = this._accounts[account.shareAccountId]![0];
    else
      shareAccount = account;
    AccountService service = _getService(account.shareAccountId);
    Transaction transaction = await service.getTransactionDetail(txid);
    return {
      "account": account,
      "shareAccount": shareAccount,
      "transaction": transaction
    };
  }

  Future<String> getReceivingAddress(String id) async {
    Account account = this.accountList.where((acc) => acc.id == id).first;
    AccountService service = _getService(account.shareAccountId);
    String address = await service.getReceivingAddress();
    return address;
  }

  Future<String> getChangingAddress(String id) async {
    Account account = this.accountList.where((acc) => acc.id == id).first;
    AccountService service = _getService(account.shareAccountId);
    Map result = await service.getChangingAddress();
    return result['address'];
  }

  Future<Map> getTransactionFee(String id,
      {String? to,
      String? amount,
      String? message,
      TransactionPriority? priority}) async {
    Account account = this.accountList.where((acc) => acc.id == id).first;
    AccountService service = _getService(account.shareAccountId);
    late String shareAccountSymbol;
    if (account.type == 'token') {
      shareAccountSymbol = this._accounts[account.shareAccountId]![0].symbol;
      message = (service as EthereumService).tokenTxMessage(
          to: to, amount: amount, message: message, decimals: account.decimals);
      amount = '0';
      to = account.contract;
    } else
      shareAccountSymbol = account.symbol;
    Map fee = await service.getTransactionFee(
        blockchainId: account.blockchainId,
        decimals: account.decimals,
        to: to,
        amount: amount,
        message: message,
        priority: priority);
    return {"fee": fee, "shareAccountSymbol": shareAccountSymbol};
  }

  Future<bool> verifyAddress(String id, String address) async {
    bool verified = false;
    String _address = await getChangingAddress(id);
    verified = address != _address && address.length > 0;
    if (verified) {
      late TransactionService txSvc;
      Account account = this.accountList.where((acc) => acc.id == id).first;
      switch (account.accountType) {
        case ACCOUNT.BTC:
          txSvc = BitcoinTransactionService(TransactionServiceBased());
          break;
        case ACCOUNT.ETH:
        case ACCOUNT.CFC:
          txSvc = EthereumTransactionService(TransactionServiceBased());
          break;
        case ACCOUNT.XRP:
        default:
          throw Exception("unsupported currency type");
      }
      verified = txSvc.verifyAddress(
          address, account.blockchainCoinType != 1); // TODO isMainnet
    }
    return verified;
  }

  Future<dynamic> extractAddressData(String id) async {
    String _address = await getReceivingAddress(id);
    dynamic _data;

    late TransactionService txSvc;
    Account account = this.accountList.where((acc) => acc.id == id).first;
    switch (account.accountType) {
      case ACCOUNT.BTC:
        txSvc = BitcoinTransactionService(TransactionServiceBased());
        break;
      case ACCOUNT.ETH:
      case ACCOUNT.CFC:
        txSvc = EthereumTransactionService(TransactionServiceBased());
        break;
      case ACCOUNT.XRP:
      default:
        throw Exception("unsupported currency type");
    }
    _data = txSvc.extractAddressData(
        _address, account.blockchainCoinType != 1); // TODO isMainnet

    return _data;
  }

  // TODO safemath
  bool verifyAmount(String id, String amount, String fee) {
    bool verified = false;
    Account account = this.accountList.where((acc) => acc.id == id).first;
    late Account shareAccount;
    if (account.type == 'token')
      shareAccount = this._accounts[account.shareAccountId]![0];
    else
      shareAccount = account;
    Decimal amountPlusFee = Decimal.parse(amount) + Decimal.parse(fee);
    verified = account.type == 'token'
        ? Decimal.parse(shareAccount.balance) >= Decimal.parse(fee) &&
            Decimal.parse(account.balance) >= Decimal.parse(amount)
        : Decimal.parse(account.balance) > amountPlusFee;
    return verified;
  }

  Future sendTransaction(String id,
      {required String thirdPartyId,
      required String to,
      required Decimal amount,
      Decimal? fee,
      Decimal? gasPrice,
      Decimal? gasLimit,
      String? message}) async {
    Account account = this.accountList.where((acc) => acc.id == id).first;
    AccountService service = _getService(account.shareAccountId);
    late TransactionService txSvc;
    late Account shareAccount;
    late Decimal balance; // TODO
    late Transaction _transaction; // TODO
    String? _tokenTransactionAddress; // TODO
    String? _tokenTransactionAmount; // TODO
    if (account.type == 'token')
      shareAccount = this._accounts[account.shareAccountId]![0];
    else
      shareAccount = account;
    switch (account.accountType) {
      case ACCOUNT.BTC:
        Map result = await service.getChangingAddress();
        List<UnspentTxOut> utxos =
            await (service as BitcoinService).getUnspentTxOut(account.id);
        txSvc = BitcoinTransactionService(TransactionServiceBased());
        _transaction = await txSvc.prepareTransaction(
          thirdPartyId,
          account.currencyPublish,
          to,
          Converter.toCurrencySmallestUnit(amount, account.decimals),
          message: message,
          accountId: account.id,
          fee: Converter.toCurrencySmallestUnit(fee!, shareAccount.decimals),
          unspentTxOuts: utxos,
          keyIndex: result['keyIndex'],
          changeAddress: result['address'],
        );
        balance = Decimal.parse(account.balance) - amount - fee;
        break;
      case ACCOUNT.ETH:
      case ACCOUNT.CFC:
        if (account.type == 'token') {
          // ERC20
          _tokenTransactionAmount = amount.toString();
          _tokenTransactionAddress = to;
          message = (service as EthereumService).tokenTxMessage(
              to: to,
              amount: amount.toString(),
              message: message,
              decimals: account.decimals);
          balance = Decimal.parse(account.balance) - amount; // currency unint
          amount = Decimal.zero;
          to = account.contract!;
        } else {
          balance = Decimal.parse(account.balance) - amount - fee!;
        }
        int nonce = await (service as EthereumService)
            .getNonce(account.blockchainId, await getReceivingAddress(id));
        txSvc = EthereumTransactionService(TransactionServiceBased());
        _transaction = await txSvc.prepareTransaction(
            thirdPartyId,
            account
                .currencyPublish, // ++ debugInfo, isMainnet required not publish, null-safety
            to,
            Converter.toCurrencySmallestUnit(amount, account.decimals),
            message: message,
            nonce: nonce,
            gasPrice: Converter.toCurrencySmallestUnit(
                gasPrice!, shareAccount.decimals),
            gasLimit: gasLimit,
            chainId: account.chainId,
            changeAddress: await getReceivingAddress(id));
        break;
      case ACCOUNT.XRP:
      default:
        throw Exception("unsupported currency type");
    }
    List result =
        await service.publishTransaction(account.blockchainId, _transaction);
    bool success = result[0];
    Transaction _sentTransaction = result[1];
    AccountEntity? accountEntity =
        await DBOperator().accountDao.findAccount(id);
    Log.warning('PublishTransaction _updateAccount id: $id');

    AccountEntity updateAccountEntity =
        accountEntity!.copyWith(balance: balance.toString());
    await DBOperator().accountDao.insertAccount(updateAccountEntity);

    TransactionEntity tx = TransactionEntity.fromTransaction(
        account,
        _sentTransaction,
        account.type == "token" ? _tokenTransactionAmount! : amount.toString(),
        fee.toString(),
        gasPrice.toString(),
        account.type == "token" ? _tokenTransactionAddress! : to);
    await DBOperator().transactionDao.insertTransaction(tx);

    if (account.type == "token") {
      accountEntity =
          await DBOperator().accountDao.findAccount(account.shareAccountId);
      Log.warning(
          'PublishTransaction _updateAccount id: ${account.shareAccountId}');

      updateAccountEntity = accountEntity!.copyWith(
          balance: (Decimal.parse(accountEntity.balance) - fee!).toString());
      await DBOperator().accountDao.insertAccount(updateAccountEntity);

      tx = TransactionEntity.fromTransaction(account, _sentTransaction, '0',
          fee.toString(), gasPrice.toString(), _tokenTransactionAddress);
      await DBOperator().transactionDao.insertTransaction(tx);
    }
  }
}
