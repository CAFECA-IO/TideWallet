class Account {
  final int cointype;
  final int purpose;
  final String symbol;
  final String imgPath;
  final String amount;
  final String fiat;

  Account(
      {this.cointype,
      this.purpose,
      this.amount,
      this.fiat,
      this.imgPath,
      this.symbol});

  copyWith(
    int cointype,
    int purpose,
    String symbol,
    String imgPath,
    String amount,
    String fiat,
  ) {
    return Account(
      cointype: cointype ?? this.cointype,
      purpose: purpose ?? this.purpose,
      amount: amount ?? this.amount,
      fiat: fiat ?? this.fiat,
      symbol: symbol ?? this.symbol,
      imgPath: imgPath ?? this.imgPath,
    );
  }
}
