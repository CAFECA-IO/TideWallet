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

  Future coreInit({bool? debugMode}) async {
    bool isInit = debugMode != null && this._debugMode != debugMode;
    if (isInit) {
      this._debugMode = debugMode;
      this._prefManager.setDebugMode(debugMode);
    }

    if (!AccountCore().isInit || isInit) {
      AccountCore().setMessenger();

      return await AccountCore().init(debugMode: this.debugMode);
    }

    return Future.delayed(Duration(seconds: 0));
  }

  List<Account> getAllAccounts() {
    return AccountCore().getAllAccounts();
  }

  List<Account> getAccounts(String accountId) {
    return AccountCore().getAccountsByShareAccountId(accountId)!;
  }

  bool validateETHAddress(String address) {
    return verifyEthereumAddress(address);
  }

  Future<Token?> getTokenInfo(String bkid, String address) {
    return EthereumService.getTokeninfo(bkid, address);
  }

  Future<bool> addToken(Account account, Token token) async {
    AccountService _ethService = AccountCore().getService(account.id);

    return (_ethService as EthereumService)
        .addToken(account.blockchainId, token);
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

  Future<Map?> getSeletedDisplay() {
    return this._prefManager.getSeletedDisplay();
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
}
