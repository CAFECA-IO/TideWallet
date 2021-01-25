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
      return {
        "success": false
      };
    }
  }
