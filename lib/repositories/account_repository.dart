import 'package:rxdart/subjects.dart';
import 'package:tidewallet3/services/account_service.dart';

import '../models/account.model.dart';
import '../cores/account.dart';
import '../constants/account_config.dart';
import '../services/ethereum_service.dart';
import '../helpers/ethereum_based_utils.dart';
import '../helpers/prefer_manager.dart';

class AccountRepository {
  PublishSubject<AccountMessage> get listener => AccountCore().messenger;
  PrefManager _prefManager = PrefManager();
  Map _preferDisplay = {};

  Map get preferDisplay => this._preferDisplay;
  // Map<String, List<DisplayCurrency>> get displayCurrencies => AccountCore().settingOptions;
  List<DisplayCurrency> get displayCurrencies => AccountCore().settingOptions;

  AccountRepository() {
    this
        ._prefManager
        .getSeletedDisplay()
        .then((value) => this._preferDisplay = value);

    AccountCore().setMessenger();
  }

  Future coreInit({bool debugMode = false}) async {
    if (!AccountCore().isInit || debugMode) {
      AccountCore().setMessenger();

      return await AccountCore().init(debugMode: debugMode);
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
    // AccountCore().close();
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
