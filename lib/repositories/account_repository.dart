import 'package:rxdart/subjects.dart';

import '../models/account.model.dart';
import '../cores/account.dart';
import '../constants/account_config.dart';
import '../services/ethereum_service.dart';
import '../helpers/ethereum_based_utils.dart';

class AccountRepository {
  PublishSubject<AccountMessage> get listener => AccountCore().messenger;

  AccountRepository() {
    AccountCore().setMessenger();
  }

  Future coreInit({bool debugMode = false}) {
    if (!AccountCore().isInit || debugMode) {
      return AccountCore().init(debugMode: debugMode);
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
}
