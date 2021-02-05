import 'package:floor/floor.dart';

import '../entity/currency.dart';

@dao
abstract class CurrencyDao {
  @insert
  Future<void> insertCurrency(Currency currency);

  @insert
  Future<List<int>> insertCurrencies(List<Currency> currencies);
}