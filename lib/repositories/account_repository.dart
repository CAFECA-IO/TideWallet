import 'package:rxdart/subjects.dart';

import '../models/account.model.dart';
import '../cores/account.dart';
import '../constants/account_config.dart';

class AccountRepository {
  PublishSubject<AccountMessage> get listener => AccountCore().messenger;

  AccountRepository() {
    AccountCore().setMessenger();
  }

  Future coreInit() {
    if (!AccountCore().isInit)  {
      return AccountCore().init();
    }

    return Future.delayed(Duration(seconds: 0));
  }

  // get accounts => AccountCore().accounts;

  List<Currency> getCurrencies(ACCOUNT acc) {
    return AccountCore().currencies[acc];
  }
}
