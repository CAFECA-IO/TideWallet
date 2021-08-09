import 'package:rxdart/subjects.dart';
import 'package:tidewallet3/services/account_service.dart';

import '../cores/account.dart';
import '../models/account.model.dart';
import '../services/ethereum_service.dart';
import '../helpers/ethereum_based_utils.dart';
import '../helpers/prefer_manager.dart';

class AccountRepository {
  PublishSubject<AccountMessage> get listener => AccountCore().messenger;
  PrefManager _prefManager = PrefManager();
  Map _preferDisplay = {};
  bool _debugMode = false;

  Map get preferDisplay => this._preferDisplay;
  bool get debugMode => this._debugMode;
  List<DisplayCurrency> get displayCurrencies => AccountCore().settingOptions;

  AccountRepository() {
    AccountCore().setMessenger();
  }

  Future coreInit({bool debugMode}) async {
    bool isInit = debugMode != null && this._debugMode != debugMode;
    if (debugMode != null) {
      this._prefManager.setDebugMode(debugMode);
    }

    this._debugMode = debugMode ?? await this._prefManager.getDebugMode();

    if (!AccountCore().isInit || isInit) {
      AccountCore().setMessenger();
      this._preferDisplay = await this._prefManager.getSeletedDisplay();
      return await AccountCore().init(debugMode: this.debugMode);
    }

    return Future.delayed(Duration(seconds: 0));
  }

  List<Currency> getAllCurrencies() {
    return AccountCore().getAllCurrencies();
  }

  List<Currency> getCurrencies(String accountId) {
    return AccountCore().getCurrencies(accountId);
  }

  bool validateETHAddress(String address) {
    return verifyEthereumAddress(address);
  }

  Future<Token> getTokenInfo(String bkid, String address) {
    return EthereumService.getTokeninfo(bkid, address);
  }

  Future<bool> addToken(Currency currency, Token token) async {
    EthereumService _ethService = AccountCore().getService(currency.accountId);

    return _ethService.addToken(currency.blockchainId, token);
  }

  close() {
    AccountCore().messenger.add(
          AccountMessage(evt: ACCOUNT_EVT.ClearAll),
        );
    AccountCore().messenger.add(
          AccountMessage(evt: ACCOUNT_EVT.ClearAll),
        );
    AccountCore().close();
  }

  Future<Map> getSeletedDisplay() {
    return this._prefManager.getSeletedDisplay();
  }

  Future toggleDisplay(Currency currency, bool value) async {
    final result = await this
        ._prefManager
        .setSelectedDisplay(currency.accountId, currency.currencyId, value);
    this._preferDisplay = result;

    if (value == true) {
      AccountService _service = AccountCore().getService(currency.accountId);
      _service.synchro(force: true);
    } else {
      AccountMessage msg = AccountMessage(
          evt: ACCOUNT_EVT.ToggleDisplayCurrency, value: currency.currencyId);

      AccountCore().messenger.add(msg);
    }

    return this._preferDisplay;
  }
}
