import 'package:floor/floor.dart';

import '../entity/exchage_rate.dart';

@dao
abstract class ExchangeRateDao {
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertExchangeRates(List<ExchangeRateEntity> rates);

  // @Query('SELECT * FROM ExchangeRate')
  // Future<List<ExchangeRateEntity>> findAllExchageRates();
}
