import 'package:rxdart/subjects.dart';

import '../models/account.model.dart';
import '../cores/account.dart';
import '../constants/account_config.dart';
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
    return AccountCore().currencies[acc];
  }

  Future<String> getReceivingAddress(Currency curr) async {
    await Future.delayed(Duration(seconds: 3));
    return randomHex(32);
    // return await AccountCore().getReceivingAddress(curr);
  }
}
