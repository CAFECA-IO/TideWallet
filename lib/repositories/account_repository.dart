import 'package:tidewallet3/models/transaction.model.dart';

import '../models/account.model.dart';

class AccountRepository {
  bool validAddress(String address) {
    return address.length < 32 ? false : true;
  }

  bool validAmount(String amount,
      {TransactionPriority priority, String gasLimit, String gasPrice}) {
    return amount.length > 4 ? false : true;
  }
}
