import 'package:decimal/decimal.dart';

import '../models/account.model.dart';
import '../cores/trader.dart';

class TraderRepository {
  Trader _trader = Trader();

  late Fiat _selectedFiat;
  get selectedFiat => this._selectedFiat;
  set setFiat(_fiat) => this._selectedFiat = _fiat;

  Future<List<Fiat>> getFiatList() => _trader.getFiatList();

  Future<Fiat> getSelectedFiat() => _trader.getSelectedFiat();

  Decimal calculateToFiat(Account _curr) {
    return _trader.calculateToUSD(_curr) / _selectedFiat.exchangeRate;
  }

  Decimal calculateToUSD(Account _curr) {
    return _trader.calculateToUSD(_curr);
  }

  Decimal calculateAmountToUSD(Account _curr, Decimal _amount) {
    return _trader.calculateAmountToUSD(_curr, _amount);
  }

  Decimal calculateAmountToFiat(Account _curr, Decimal _amount) {
    return _trader.calculateAmountToUSD(_curr, _amount) /
        _selectedFiat.exchangeRate;
  }

  Future changeSelectedFiat(Fiat fiat) async {
    this._selectedFiat = fiat;
    await this._trader.setSelectedFiat(fiat);
  }

  Map<String, Decimal> getSwapRateAndAmount(
      Account _sellCurr, Account _buyCurr, Decimal _amount) {
    return _trader.getSwapRateAndAmount(_sellCurr, _buyCurr, _amount);
  }
}
