import 'package:floor/floor.dart';

@Entity(tableName: 'Currency')
class CurrencyEntity {
  @primaryKey
  @ColumnInfo(name: 'currency_id')
  final String currencyId;

  final String name;

  final String description;

  final String symbol;

  final int decimals;

  final String address;

  final String type;

  @ColumnInfo(name: 'total_supply')
  final String totalSupply;

  final String contract;

  final String image;

  CurrencyEntity({
    this.currencyId,
    this.name,
    this.symbol,
    this.description,
    this.address,
    this.contract,
    this.decimals,
    this.totalSupply,
    this.type,
    this.image,
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
