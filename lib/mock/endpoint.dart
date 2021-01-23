import 'dart:math';

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
    "fiat": (v * 3000 ).toString()
  };
}
