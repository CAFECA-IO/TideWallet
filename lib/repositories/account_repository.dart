import 'package:rxdart/subjects.dart';
import '../helpers/logger.dart';

// import '../services/ethereum_service.dart';
// import '../services/account_service.dart';
// import '../helpers/prefer_manager.dart';
// import '../helpers/ethereum_based_utils.dart';

import '../models/account.model.dart';
import '../cores/account.dart';

class AccountRepository {
  PublishSubject<AccountMessage> get listener => AccountCore().messenger;

  AccountRepository() {
    AccountCore().setMessenger();
  }

  Future coreInit({bool? debugMode}) async {
    AccountCore().setMessenger();

    await AccountCore().init(debugMode: debugMode);
  }

  Future<Map> getOverview() => AccountCore().getOverview();

  List<Account> getAllAccounts() => AccountCore().getAllAccounts();

  List<Account> getAccounts(String accountId) {
    return AccountCore().getAccountsByShareAccountId(accountId)!;
  }

  Future<List<DisplayToken>> getDisplayTokens() =>
      AccountCore().getDisplayTokens();

  Future toggleDisplayToken(DisplayToken token) =>
      AccountCore().toggleDisplayToken(token);

  close() {
    AccountCore().messenger.add(
          AccountMessage(evt: ACCOUNT_EVT.ClearAll),
        );
    AccountCore().close();
  }
}
