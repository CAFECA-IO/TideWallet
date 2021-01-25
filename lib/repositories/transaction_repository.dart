import 'package:rxdart/subjects.dart';
import '../cores/account.dart';
import '../models/account.model.dart';
import '../models/transaction.model.dart';

class TransactionRepository {
  PublishSubject<AccountMessage> get listener => AccountCore().messenger;

  TransactionRepository() {
    // AccountCore().setMessenger();
  }

  bool validAddress(String address) {
    return address.length < 8 ? false : true;
  }

  bool validAmount(String amount,
      {TransactionPriority priority, String gasLimit, String gasPrice}) {
    return amount.length > 4 ? false : true;
  }

  Future<Map<TransactionPriority, String>> fetchGasPrice() async {
    await Future.delayed(Duration(seconds: 1));
    return {
      TransactionPriority.slow: "33.46200020",
      TransactionPriority.standard: "43.20000233",
      TransactionPriority.fast: "56.82152409"
    };
  }

  Future<String> fetchGasLimit() async {
    await Future.delayed(Duration(seconds: 1));
    return '25148';
  }

  Future<bool> createTransaction(List<dynamic> condition) async {
    // create
    // sign
    // publish
    await Future.delayed(Duration(seconds: 5));
    return true;
  }

  List<Transaction> getTransactionsFromDB(Currency currency) {
    // todo getTransactionFromDB
  }
}
