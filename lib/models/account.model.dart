import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../constants/account_config.dart';

enum ACCOUNT_EVT { OnUpdateAccount, OnUpdateCurrency, OnUpdateTransactions }

class Currency {
  final int cointype;
  final int purpose;
  final int accountIndex;
  final String symbol;
  final String imgPath;
  final String amount;
  final String inUSD;
  final String name;
  final ACCOUNT accountType;
  final String blockchainId;
  final int chainId;

  Currency(
      {
      this.cointype,
      this.purpose,
      this.amount,
      this.inUSD,
      this.imgPath,
      this.symbol,
      this.name,
      this.accountIndex,
      this.accountType,
      this.blockchainId,
      this.chainId,
    });

  Currency copyWith({
    int cointype,
    int purpose,
    String symbol,
    String imgPath,
    String amount,
    String inUSD,
    String name,
    ACCOUNT accountType,
    String blockchainId,
    int chainId,
  }) {
    return Currency(
      cointype: cointype ?? this.cointype,
      purpose: purpose ?? this.purpose,
      amount: amount ?? this.amount,
      inUSD: inUSD ?? this.inUSD,
      symbol: symbol ?? this.symbol,
      imgPath: imgPath ?? this.imgPath,
      name: name ?? this.name,
      accountType: accountType ?? this.accountType,
      blockchainId: blockchainId ?? this.blockchainId,
      chainId: chainId ?? this.chainId,
    );
  }

  Currency.fromMap(
    Map map,
  )   : 
        cointype = map['cointype'],
        purpose = map['purpose'],
        accountIndex = map['accountIndex'],
        symbol = map['symbol'],
        name = map['name'],
        imgPath = map['imgPath'],
        amount = map['balance'] ?? '0',
        inUSD = map['inUSD'] ?? '0',
        accountType = map['accountType'],
        blockchainId = map['blockchain_id'],
        chainId = map['chain_id'];
}

class AccountMessage {
  final ACCOUNT_EVT evt;
  final value;

  AccountMessage({@required this.evt, this.value});
}

class Token {
  final String symbol;
  final String name;
  final int decimal;
  final String imgUrl;
  final int totalSupply;
  final String contract;
  final String description;

  Token(
      {this.symbol,
      this.name,
      this.decimal,
      this.imgUrl,
      this.totalSupply,
      this.contract,
      this.description});
}

class Fiat {
  final String name;
  final Decimal exchangeRate;

  Fiat({this.name, this.exchangeRate});

  Fiat.fromMap(Map map)
      : name = map['name'],
        exchangeRate = Decimal.tryParse(map['rate']);
}
