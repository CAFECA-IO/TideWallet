import 'package:rxdart/subjects.dart';

import '../models/account.model.dart';
import '../cores/account.dart';
import '../constants/account_config.dart';
import '../services/ethereum_service.dart';

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

  Future<Token> getTokenInfo(String bkid, String address) {
    return EthereumService.getTokeninfo(bkid, address);
  }

  Future<bool> addToken(String bkid, Token token) async {
    EthereumService _ethService = AccountCore().getService(ACCOUNT.ETH);

    return _ethService.addToken(bkid, token);
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
