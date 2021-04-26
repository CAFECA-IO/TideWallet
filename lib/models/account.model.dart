import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../database/entity/exchage_rate.dart';
import '../database/entity/account_currency.dart';
import '../constants/account_config.dart';

enum ACCOUNT_EVT {
  OnUpdateAccount,
  OnUpdateCurrency,
  OnUpdateTransactions,
  OnUpdateTransaction,
  ClearAll
}

class Currency {
  final String id; // AccountCurrencyEntity id for Backend
  final String accountId;
  final int cointype;
  final int purpose;
  final int accountIndex;
  final String symbol;
  final String imgPath;
  String amount;
  final String inUSD;
  final String name;
  final ACCOUNT accountType;
  final String blockchainId;
  final String network;
  final int chainId;
  final int decimals;
  final bool publish;
  final String currencyId; // CurrencyEntity currency_id for APP
  final String contract;
  final String type;
  final String accountSymbol;
  final int accountDecimals;
  final String accountAmount;

  Currency({
    this.id,
    this.accountId,
    this.cointype,
    this.purpose,
    this.amount,
    this.inUSD,
    this.imgPath,
    this.symbol,
    this.name,
    this.accountIndex,
    this.accountType,
    this.chainId,
    this.blockchainId,
    this.network,
    this.decimals,
    this.publish,
    this.currencyId,
    this.contract,
    this.type,
    this.accountSymbol,
    this.accountDecimals,
    this.accountAmount,
  });

  Currency copyWith(
      {String id,
      String accountId,
      int cointype,
      int purpose,
      String symbol,
      String imgPath,
      String amount,
      String inUSD,
      String name,
      ACCOUNT accountType,
      String blockchainId,
      String network,
      int chainId,
      int decimals,
      bool publish,
      String contract,
      String type,
      String accountSymbol,
      int accountDecimals,
      String accountAmount}) {
    return Currency(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      cointype: cointype ?? this.cointype,
      purpose: purpose ?? this.purpose,
      amount: amount ?? this.amount,
      inUSD: inUSD ?? this.inUSD,
      symbol: symbol ?? this.symbol,
      imgPath: imgPath ?? this.imgPath,
      name: name ?? this.name,
      accountType: accountType ?? this.accountType,
      blockchainId: blockchainId ?? this.blockchainId,
      network: network ?? this.network,
      chainId: chainId ?? this.chainId,
      decimals: decimals ?? this.decimals,
      publish: publish ?? this.publish,
      contract: contract ?? this.contract,
      type: type ?? this.type,
      accountSymbol: accountSymbol ?? this.accountSymbol,
      accountDecimals: accountDecimals ?? this.accountDecimals,
      accountAmount: accountAmount ?? this.accountAmount,
    );
  }

  // Currency.fromMap(
  //   Map map,
  // )   : id = map['currency_id'],
  //       accountId = map['account_id'],
  //       cointype = map['cointype'],
  //       purpose = map['purpose'],
  //       accountIndex = map['accountIndex'],
  //       symbol = map['symbol'],
  //       name = map['name'],
  //       imgPath = map['imgPath'],
  //       amount = map['balance'] ?? '0',
  //       inUSD = map['inUSD'] ?? '0',
  //       accountType = map['accountType'],
  //       blockchainId = map['blockchain_id'],
  //       network = map['network'],
  //       chainId = map['chain_id'],
  //       decimals = map['decimals'],
  //       publish = map['publish'],
  //       currencyId = map['currency_id'],
  //       contract = map['contract'],
  //       type = map['type'];

  Currency.fromJoinCurrency(
      JoinCurrency entity, JoinCurrency parentEntity, ACCOUNT type)
      : id = entity.accountcurrencyId,
        accountId = entity.accountId,
        cointype = entity.coinType,
        purpose = null, // Dreprecated
        accountIndex = entity.accountIndex,
        symbol = entity.symbol,
        name = entity.name,
        imgPath = entity.image,
        inUSD = '0',
        accountType = type,
        amount = entity.balance,
        blockchainId = entity.blockchainId,
        network = entity.network,
        chainId = entity.chainId,
        publish = entity.publish,
        currencyId = entity.currencyId,
        contract = entity.contract,
        decimals = entity.decimals,
        type = entity.type,
        accountDecimals = parentEntity.decimals,
        accountSymbol = parentEntity.symbol,
        accountAmount = parentEntity.balance;
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
  final String totalSupply;
  final String contract;
  final String description;

  Token({
    this.symbol,
    this.name,
    this.decimal,
    this.imgUrl,
    this.totalSupply,
    this.contract,
    this.description,
  });
}

class Fiat {
  final String currencyId;
  final String name;
  final Decimal exchangeRate;

  Fiat({this.currencyId, this.name, this.exchangeRate});

  Fiat.fromMap(Map map)
      : currencyId = map['currency_id'],
        name = map['name'],
        exchangeRate = Decimal.tryParse(map['rate']);

  // Fiat.fromExChangeRateCurrencyEntity(ExchageRateCurrency entity)
  //     : name = entity.symbol,
  //       exchangeRate = Decimal.parse(entity.rate);

  Fiat.fromExchangeRateEntity(ExchangeRateEntity entity)
      : currencyId = entity.exchangeRateId,
        name = entity.name,
        exchangeRate = Decimal.parse(entity.rate);
}
