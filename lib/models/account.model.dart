import 'package:flutter/material.dart';

enum ACCOUNT_EVT { 
  OnUpdateAccount,
  OnBalanceChanged }

class Account {
  final int cointype;
  final int purpose;
  final int accountIndex;
  final String symbol;
  final String imgPath;
  final String amount;
  final String fiat;
  final String name;

  Account({
    this.cointype,
    this.purpose,
    this.amount,
    this.fiat,
    this.imgPath,
    this.symbol,
    this.name,
    this.accountIndex,
  });

  copyWith(
    int cointype,
    int purpose,
    String symbol,
    String imgPath,
    String amount,
    String fiat,
    String name,
  ) {
    return Account(
      cointype: cointype ?? this.cointype,
      purpose: purpose ?? this.purpose,
      amount: amount ?? this.amount,
      fiat: fiat ?? this.fiat,
      symbol: symbol ?? this.symbol,
      imgPath: imgPath ?? this.imgPath,
      name: name ?? this.name
    );
  }

  Account.fromMap(
    Map map,
  )   : cointype = map['cointype'],
        purpose = map['purpose'],
        accountIndex = map['accountIndex'],
        symbol = map['symbol'],
        name = map['name'],
        imgPath = map['imgPath'],
        amount = map['amount'] ?? '0',
        fiat = map['fiat'] ?? '0';
}

class AccountMessage {
  final ACCOUNT_EVT evt;
  final value;

  AccountMessage({@required this.evt, this.value});
}
