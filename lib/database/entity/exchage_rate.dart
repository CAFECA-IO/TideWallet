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

  final String type;

  ExchangeRateEntity({
    this.exchangeRateId,
    this.rate,
    this.lastSyncTime,
    this.type,
  });

  ExchangeRateEntity.fromJson(Map json):
    this.exchangeRateId = json['name'],
    this.rate = json['rate'],
    this.lastSyncTime = json['timestamp'],
    this.type = json['type'];
}
