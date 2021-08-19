import 'package:decimal/decimal.dart';

import '../models/account.model.dart';
import '../cores/trader.dart';

class TraderRepository {
  Trader _trader = Trader();

  Future<List<Fiat>> getFiatList() => _trader.getFiatList();

  Future<Fiat> getSelectedFiat() => _trader.getSelectedFiat();

  Future<Decimal> calculateToFiat(Account acc) => _trader.calculateToFiat(acc);

  Future<Decimal> calculateAmountToFiat(Account acc, Decimal amount) =>
      _trader.calculateAmountToFiat(acc, amount);

  Decimal calculateToUSD(Account acc) {
    return _trader.calculateToUSD(acc);
  }

  Decimal calculateAmountToUSD(Account acc, Decimal amount) {
    return _trader.calculateAmountToUSD(acc, amount);
  }

  Future setSelectedFiat(Fiat fiat) => this._trader.setSelectedFiat(fiat);

  Map<String, Decimal> getSwapRateAndAmount(
      Account _sellCurr, Account _buyCurr, Decimal _amount) {
    return _trader.getSwapRateAndAmount(_sellCurr, _buyCurr, _amount);
  }
}
