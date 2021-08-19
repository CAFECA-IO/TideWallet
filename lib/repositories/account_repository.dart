import 'package:rxdart/subjects.dart';

import '../models/account.model.dart';
import '../cores/account.dart';

class AccountRepository {
  PublishSubject<AccountMessage> get listener => AccountCore().messenger;

  AccountRepository();

  Future coreInit({bool? debugMode}) async {
    await AccountCore().init(debugMode: debugMode);
  }

  Future<Map> getOverview() => AccountCore().getOverview();

  // Future<Fiat> getSelectedFiat() => AccountCore().getSelectedFiat();

  Future<List<DisplayToken>> getDisplayTokens() =>
      AccountCore().getDisplayTokens();

  Future toggleDisplayToken(DisplayToken token) =>
      AccountCore().toggleDisplayToken(token);

  List<Account> get accountList => AccountCore().accountList;
  Map<String, List<Account>> get accountMap => AccountCore().accounts;

  close() {
    AccountCore().messenger.add(
          AccountMessage(evt: ACCOUNT_EVT.ClearAll),
        );
    AccountCore().close();
  }
}
