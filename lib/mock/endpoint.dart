Future<List<Map>> getETHTokens() async {
  await Future.delayed(Duration(seconds: 1));

  return [
    {
      "name": "XPA",
      "symbol": "XPA",
      "imgPath": "",
      "fiat": "1000",
      "amount": "1000"
    }
  ];
}