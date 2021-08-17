import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

import '../database/entity/account.dart';
import '../database/entity/currency.dart';
import '../database/entity/exchage_rate.dart';
import '../constants/account_config.dart';

enum ACCOUNT_EVT {
  OnUpdateAccount,
  OnUpdateAccounts,
  OnUpdateTransactions,
  OnUpdateTransaction,
  ClearAll,
  ToggleDisplayCurrency
}

class Account {
  final String id;
  final String shareAccountId;
  final String userId;
  final String blockchainId;
  final String currencyId; // CurrencyEntity currency_id for APP
  final int purpose;
  final int accountCoinType;
  final int accountIndex;
  final int curveType;
  String balance;
  final int numberOfUsedExternalKey;
  final int numberOfUsedInternalKey;
  final int? lastSyncTime;
  final String keystore;
  final String network;
  final int blockchainCoinType;
  final int chainId;
  final String name;
  final String symbol;
  final String type;
  final bool publish;
  final int decimals;
  final String exchangeRate;
  final String imgPath;
  final String? contract;

  Decimal? inFiat;
  final ACCOUNT accountType;
  final String shareAccountSymbol;
  final int shareAccountDecimals;
  final String shareAccountAmount;

  Account(
      {required this.id,
      required this.shareAccountId,
      required this.userId,
      required this.blockchainId,
      required this.currencyId,
      required this.purpose,
      required this.accountCoinType,
      required this.accountIndex,
      required this.curveType,
      required this.balance,
      required this.numberOfUsedExternalKey,
      required this.numberOfUsedInternalKey,
      required this.lastSyncTime,
      required this.keystore,
      required this.network,
      required this.blockchainCoinType,
      required this.chainId,
      required this.name,
      required this.symbol,
      required this.type,
      required this.publish,
      required this.contract,
      required this.decimals,
      required this.exchangeRate,
      required this.imgPath,
      required this.accountType,
      required this.shareAccountSymbol,
      required this.shareAccountDecimals,
      required this.shareAccountAmount});

  Account copyWith({
    String? id,
    String? shareAccountId,
    String? userId,
    String? blockchainId,
    String? currencyId,
    int? purpose,
    int? accountCoinType,
    int? accountIndex,
    int? curveType,
    String? balance,
    int? numberOfUsedExternalKey,
    int? numberOfUsedInternalKey,
    int? lastSyncTime,
    String? keystore,
    String? network,
    int? blockchainCoinType,
    int? chainId,
    String? name,
    String? symbol,
    String? type,
    bool? publish,
    String? contract,
    int? decimals,
    String? exchangeRate,
    String? imgPath,
    Decimal? inFiat,
    ACCOUNT? accountType,
    String? shareAccountSymbol,
    int? shareAccountDecimals,
    String? shareAccountAmount,
  }) {
    return Account(
      id: id ?? this.id,
      shareAccountId: shareAccountId ?? this.shareAccountId,
      userId: userId ?? this.userId,
      blockchainId: blockchainId ?? this.blockchainId,
      currencyId: currencyId ?? this.currencyId,
      purpose: purpose ?? this.purpose,
      accountCoinType: accountCoinType ?? this.accountCoinType,
      accountIndex: accountIndex ?? this.accountIndex,
      curveType: curveType ?? this.curveType,
      balance: balance ?? this.balance,
      numberOfUsedExternalKey:
          numberOfUsedExternalKey ?? this.numberOfUsedExternalKey,
      numberOfUsedInternalKey:
          numberOfUsedInternalKey ?? this.numberOfUsedInternalKey,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      keystore: keystore ?? this.keystore,
      network: network ?? this.network,
      blockchainCoinType: blockchainCoinType ?? this.blockchainCoinType,
      chainId: chainId ?? this.chainId,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      type: type ?? this.type,
      publish: publish ?? this.publish,
      contract: contract ?? this.contract,
      decimals: decimals ?? this.decimals,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      imgPath: imgPath ?? this.imgPath,
      accountType: accountType ?? this.accountType,
      shareAccountSymbol: shareAccountSymbol ?? this.shareAccountSymbol,
      shareAccountDecimals: shareAccountDecimals ?? this.shareAccountDecimals,
      shareAccountAmount: shareAccountAmount ?? this.shareAccountAmount,
    );
  }

  Account.fromJoinAccount(
      JoinAccount entity, JoinAccount sharedEntity, ACCOUNT type)
      : id = entity.id,
        shareAccountId = entity.shareAccountId,
        accountCoinType = entity.accountCoinType,
        purpose = entity.purpose, // Dreprecated
        accountIndex = entity.accountIndex,
        symbol = entity.symbol,
        name = entity.name,
        imgPath = entity.image,
        balance = entity.balance,
        blockchainId = entity.blockchainId,
        network = entity.network,
        chainId = entity.chainId,
        publish = entity.publish,
        contract = entity.contract,
        currencyId = entity.currencyId,
        decimals = entity.decimals,
        type = entity.type,
        userId = entity.userId,
        curveType = entity.curveType,
        numberOfUsedExternalKey = entity.numberOfUsedExternalKey ?? 0,
        numberOfUsedInternalKey = entity.numberOfUsedInternalKey ?? 0,
        lastSyncTime = entity.lastSyncTime,
        keystore = entity.keystore,
        blockchainCoinType = entity.blockchainCoinType,
        exchangeRate = entity.exchangeRate ?? "0",
        accountType = type,
        shareAccountSymbol = sharedEntity.symbol,
        shareAccountDecimals = sharedEntity.decimals,
        shareAccountAmount = sharedEntity.balance;
}

class AccountMessage {
  final ACCOUNT_EVT evt;
  final value;

  AccountMessage({required this.evt, this.value});
}

class Token {
  final String imgUrl;
  final String contract;
  final String? symbol;
  final String? name;
  final int? decimal;
  final String? totalSupply;
  final String? description;

  Token({
    required this.imgUrl,
    required this.contract,
    this.symbol,
    this.name,
    this.decimal,
    this.totalSupply,
    this.description,
  });
}

class Fiat {
  final String currencyId;
  final String name;
  final Decimal exchangeRate;

  Fiat(
      {required this.currencyId,
      required this.name,
      required this.exchangeRate});

  Fiat.fromMap(Map map)
      : currencyId = map['currency_id'],
        name = map['name'],
        exchangeRate = Decimal.tryParse(map['rate'])!;

  // Fiat.fromExChangeRateCurrencyEntity(ExchageRateCurrency entity)
  //     : name = entity.symbol,
  //       exchangeRate = Decimal.parse(entity.rate);

  Fiat.fromExchangeRateEntity(ExchangeRateEntity entity)
      : currencyId = entity.exchangeRateId,
        name = entity.name,
        exchangeRate = Decimal.parse(entity.rate);
}

class DisplayCurrency extends Equatable {
  final bool editable;
  final bool opened;
  final String symbol;
  final String name;
  final String icon;
  final String currencyId;
  final String contract;
  final String blockchainId;

  DisplayCurrency({
    this.editable = false,
    this.opened = false,
    required this.symbol,
    required this.name,
    required this.icon,
    required this.currencyId,
    required this.contract,
    required this.blockchainId,
  });

  DisplayCurrency copyWith({
    bool? opened,
    bool? editable,
    String? symbol,
    String? name,
    String? icon,
    String? currencyId,
    String? contract,
    String? blockchainId,
  }) {
    return DisplayCurrency(
        opened: opened ?? this.opened,
        editable: editable ?? this.editable,
        symbol: symbol ?? this.symbol,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        currencyId: currencyId ?? this.currencyId,
        contract: contract ?? this.contract,
        blockchainId: blockchainId ?? this.blockchainId);
  }

  DisplayCurrency.fromCurrencyEntity(CurrencyEntity entity)
      : opened = false,
        editable = false,
        symbol = entity.symbol,
        name = entity.name,
        icon = entity.image!,
        currencyId = entity.currencyId,
        contract = entity.contract!,
        blockchainId = entity.blockchainId!;

  @override
  List<Object> get props => [opened];
}
