import 'package:tidewallet3/models/transaction.model.dart';

import '../models/account.model.dart';

class AccountRepository {
  bool validAddress(String address) {
    return address.length < 8 ? false : true;
  }

  bool validAmount(String amount,
      {TransactionPriority priority, String gasLimit, String gasPrice}) {
    return amount.length > 4 ? false : true;
  }

  Future<Map<TransactionPriority, String>> fetchGasPrice() async {
    Future.delayed(Duration(seconds: 1));
    return {
      TransactionPriority.slow: "33.46200020",
      TransactionPriority.standard: "43.20000233",
      TransactionPriority.fast: "56.82152409"
    };
  }

  Future<String> fetchGasLimit() async {
    Future.delayed(Duration(seconds: 1));
    return '25148';
  }
}
