import 'package:floor/floor.dart';

@entity
class Currency {
  @primaryKey
  @ColumnInfo(name: 'currency_id')
  final String currencyId;

  final String name;

  @ColumnInfo(name: 'coin_type')
  final int coinType;

  final String description;

  final String symbol;

  final int decimals;

  final String address;

  final String type;

  @ColumnInfo(name: 'total_supply')
  final String totalSupply;

  final String contract;

  Currency({
    this.currencyId,
    this.name,
    this.coinType,
    this.symbol,
    this.description,
    this.address,
    this.contract,
    this.decimals,
    this.totalSupply,
    this.type,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency &&
          runtimeType == other.runtimeType &&
          currencyId == other.currencyId &&
          coinType == other.coinType &&
          symbol == other.symbol;

  @override
  int get hashCode => currencyId.hashCode ^ coinType.hashCode ^ symbol.hashCode;
}
