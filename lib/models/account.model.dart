class Account {
  final int cointype;
  final int purpose;

  Account({ this.cointype, this.purpose});

  copyWith(
    coinType,
    purpose
  ) {
    return Account(cointype: cointype ?? this.cointype, purpose: purpose ?? this.purpose);
  }
}