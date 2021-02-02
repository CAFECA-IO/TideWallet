import 'dart:math';
import '../models/transaction.model.dart';
import '../helpers/utils.dart';

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

Future<Map> getETHTokeninfo(String address) async {
  await Future.delayed(Duration(seconds: 1));
  if (address.length > 10) {
    return {
      "success": true,
      "symbol": "XPA",
      "decimal": 18,
      "name": "XPA",
      "imgPath": "assets/images/xpa.png",
      "contract": "0x90528aeb3a2b736b780fd1b6c478bb7e1d643170",
      "totalSupply": 50000000,
      "description": "Hey Hey"
    };
  } else {
    return {"success": false};
  }
}

Future<List<Transaction>> getETHTransactions() async {
  List<Transaction> transactions = [];
  int v = Random().nextInt(10);
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

    transactions.add(transaction);
  }

  return transactions;
}

Future<Map<String, List<Map>>> exchangeRate() async {
  await Future.delayed(Duration(seconds: 1));

  return {
    "crypto": [
      {"name": "ETH", "rate": "1325"},
      {"name": "BTC", "rate": "31847"},
      {"name": "XRP", "rate": "0.265"},
      {"name": "XPA", "rate": "0.001"},
    ],
    "fiat": [
      {"name": "USD", "rate": "1"},
      {"name": "CNY", "rate": "0.14"},
      {"name": "TWD", "rate": "0.03"},
      {"name": "HKD", "rate": "0.14"},
      {"name": "JPY", "rate": "0.01"}
    ]
  };
}
