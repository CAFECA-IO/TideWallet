import 'package:floor/floor.dart';

@Entity(tableName: 'Currency')
class CurrencyEntity {
  @primaryKey
  @ColumnInfo(name: 'currency_id')
  final String currencyId;

  @ColumnInfo(name: 'blockchain_id')
  final String? blockchainId;

  final String? contract;

  final String name;

  final String symbol;

  final String type;

  final bool publish;

  final int decimals;

  @ColumnInfo(name: 'exchange_rate')
  final String exchangeRate;

  @ColumnInfo(name: 'total_supply')
  final String? totalSupply;

  final String?
      image; // ++ debugInfo, fiat icon is null, but crypto and token icon is not null

  CurrencyEntity(
      {required this.currencyId,
      required this.name,
      required this.symbol,
      required this.publish,
      required this.decimals,
      required this.type,
      required this.image,
      required this.exchangeRate,
      this.contract,
      this.blockchainId,
      this.totalSupply});

  CurrencyEntity copyWith({
    String? currencyId,
    String? name,
    String? symbol,
    bool? publish,
    int? decimals,
    String? type,
    String? image,
    String? exchangeRate,
    String? contract,
    String? blockchainId,
    String? totalSupply,
  }) {
    return CurrencyEntity(
      currencyId: currencyId ?? this.currencyId,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      publish: publish ?? this.publish,
      decimals: decimals ?? this.decimals,
      type: type ?? this.type,
      image: image ?? this.image,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      contract: contract ?? this.contract,
      blockchainId: blockchainId ?? this.blockchainId,
      totalSupply: totalSupply ?? this.totalSupply,
    );
  }

  CurrencyEntity.fromJson(Map json)
      : this.currencyId = json['currency_id'] ?? json['token_id'],
        this.name = json['name'],
        this.symbol = json['symbol'],
        this.decimals = json['decimals'],
        this.type = json['type'] == 0
            ? 'fiat'
            : json['type'] == 1
                ? 'currency'
                : 'token',
        this.publish = json['publish'],
        this.image = json['icon'],
        this.contract = json['contract'],
        this.blockchainId = json['blockchain_id'],
        this.exchangeRate = json['exchange_rate'] ?? "0",
        this.totalSupply = json['total_supply'];

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

@DatabaseView(
    'SELECT * FROM Currency INNER JOIN Account ON Currency.currency_id = Account.currency_id',
    viewName: 'CurrencyWithAccountId')
class AvailableTokensOnChain {
  @primaryKey
  @ColumnInfo(name: 'currency_id')
  final String currencyId;

  @ColumnInfo(name: 'blockchain_id')
  final String blockchainId;

  final String symbol;

  AvailableTokensOnChain({
    required this.currencyId,
    required this.blockchainId,
    required this.symbol,
  });
}
