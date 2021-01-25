import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:tidewallet3/models/transaction.model.dart';

Future<List<Map>> getETHTokens() async {
  await Future.delayed(Duration(seconds: 1));

  return [
    {
      "name": "XPA",
      "symbol": "XPA",
      "imgPath": "assets/images/xpa.png",
      "amount": "1000",
      "fiat": "1000"
    }
  ];
}

Future<Map> getETH() async {
  await Future.delayed(Duration(seconds: 1));
  int v = Random().nextInt(100);
  return {
    "name": "Ethereum",
    "symbol": "ETH",
    "imgPath": "assets/images/eth.png",
    "amount": v.toString(),
    "fiat": (v * 3000).toString()
  };
}

String randomHex(int length) {
  const array = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 'a', 'b', 'c', 'd', 'e', 'f'];
  String hex = ''; //      var subPSKID = [];
  for (int index = 0; index < length; index++) {
    hex += array[Random().nextInt(16)]
        .toString(); //        subPSKID.add(array[i]);
  }
  return hex;
}

Future<List<Transaction>> getETHTransactions() async {
  List<Transaction> transactions = [];
  int v = Random().nextInt(10);
  print("v: $v");
  for (int i = 0; i < v; i++) {
    TransactionDirection direction =
        TransactionDirection.values[Random().nextInt(2)];
    String amount = "${Random().nextInt(100)}.${Random().nextInt(9)}";
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    int confirmations = Random().nextInt(10);
    TransactionStatus status = confirmations > 6
        ? TransactionStatus.success
        : TransactionStatus.pending;
    String address = randomHex(32);
    String fee = "${Random().nextInt(10)}.${Random().nextInt(9)}";
    String txid = randomHex(32);
    print("status: $status");

    Transaction transaction = Transaction(
        id: randomHex(6),
        direction: direction,
        amount: amount,
        status: status,
        timestamp: timestamp,
        confirmations: confirmations,
        address: address,
        fee: fee,
        txId: txid);
    print(transaction.status);

    transactions.add(transaction);
  }

  return transactions;
}
