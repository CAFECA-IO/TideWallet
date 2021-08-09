import 'package:floor/floor.dart';

@Entity(tableName: 'Currency')
class CurrencyEntity {
  @primaryKey
  @ColumnInfo(name: 'currency_id')
  final String currencyId;

  final String name;

  final String? description;

  final String symbol;

  final int decimals;

  final String address;

  final String type;

  @ColumnInfo(name: 'total_supply')
  final String? totalSupply;

  final String? contract;

  final String image;

  CurrencyEntity({
    required this.currencyId,
    required this.name,
    required this.symbol,
    required this.description,
    required this.address,
    required this.contract,
    required this.decimals,
    required this.totalSupply,
    required this.type,
    required this.image,
  });

  CurrencyEntity.fromJson(Map json)
      : this.currencyId = json['currency_id'] ?? json['token_id'],
        this.name = json['name'],
        this.description = json['description'],
        this.address = json['contract'],
        this.contract = json['contract'],
        this.symbol = json['symbol'],
        this.decimals = json['decimals'],
        this.totalSupply = json['total_supply'],
        this.type = json['type'] == 0
            ? 'fiat'
            : json['type'] == 1
                ? 'currency'
                : 'token',
        this.image = json['icon'];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyEntity &&
          runtimeType == other.runtimeType &&
          currencyId == other.currencyId &&
          symbol == other.symbol;

  @override
  int get hashCode => currencyId.hashCode ^ symbol.hashCode;
}

// @DatabaseView(
//     'SELECT * FROM Currency INNER JOIN ExchangeRate ON Currency.currency_id = ExchangeRate.currency_id',
//     viewName: 'JoinCurrency')
// class ExchageRateCurrency {
//   @primaryKey
//   @ColumnInfo(name: 'currency_id')
//   final String currencyId;

//   final String symbol;

//   final String rate;

//   final String type;

//   ExchageRateCurrency({
//     this.currencyId,
//     this.symbol,
//     this.rate,
//     this.type,
//   });
// }

@DatabaseView(
    'SELECT * FROM Currency INNER JOIN AccountCurrency ON Currency.currency_id = AccountCurrency.currency_id',
    viewName: 'CurrencyWithAccountId')
class CurrencyWithAccountId {
  @primaryKey
  @ColumnInfo(name: 'currency_id')
  final String currencyId;

  @ColumnInfo(name: 'account_id')
  final String accountId;

  final String symbol;

  CurrencyWithAccountId({
    required this.currencyId,
    required this.accountId,
    required this.symbol,
  });
}
