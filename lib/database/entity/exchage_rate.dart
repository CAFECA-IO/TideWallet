import 'package:floor/floor.dart';

// import 'currency.dart';

@Entity(tableName: 'ExchangeRate')
class ExchangeRateEntity {
  @primaryKey
  @ColumnInfo(name: 'exchange_rate_id')
  final String exchangeRateId;

  // @ForeignKey(
  //     childColumns: ['currency_id'],
  //     parentColumns: ['currency_id'],
  //     entity: CurrencyEntity)
  // @ColumnInfo(name: 'currency_id')
  // final String currencyId;

  final String rate;

  final int lastSyncTime;

  final String symbol;

  ExchangeRateEntity(
      {this.exchangeRateId, this.symbol, this.rate, this.lastSyncTime});
}
