import 'package:rxdart/subjects.dart';

import '../models/account.model.dart';
import '../cores/account.dart';
import '../constants/account_config.dart';
import '../services/ethereum_service.dart';
import '../helpers/utils.dart';

class AccountRepository {
  PublishSubject<AccountMessage> get listener => AccountCore().messenger;

  AccountRepository() {
    AccountCore().setMessenger();
  }

  Future coreInit() {
    if (!AccountCore().isInit) {
      return AccountCore().init();
    }

    return Future.delayed(Duration(seconds: 0));
  }

  List<Currency> getCurrencies(ACCOUNT acc) {
    return AccountCore().getCurrencies(acc);
  }

  bool validateETHAddress(String address) {
    // TODO
    return address.startsWith('0x');
  }

  Future<Token> getTokenInfo(String address) {
    return EthereumService.getTokeninfo(address);
  }

  Future<bool> addToken(Token token) async {
    EthereumService _ethService = AccountCore().getService(ACCOUNT.ETH);

    return _ethService.addToken(token);
  }
}
