import 'package:decimal/decimal.dart';

import '../models/account.model.dart';
import '../cores/trader.dart';

class TraderRepository {
  Trader _trader = Trader();

  Fiat _selectedFiat;
  get selectedFiat => this._selectedFiat;
  set setFiat(_fiat) => this._selectedFiat = _fiat;

  Future<List<Fiat>> getFiatList() => _trader.getFiatList();

  Future<Fiat> getSelectedFiat() => _trader.getSelectedFiat();

  Decimal calculateToFiat(Currency _curr) {
    if (this._selectedFiat == null) {
      return Decimal.zero;
    }

    return _trader.calculateToUSD(_curr) / _selectedFiat.exchangeRate;
  }

  Decimal calculateToUSD(Currency _curr) {
    return _trader.calculateToUSD(_curr);
  }

  Decimal calculateFeeToUSD(Currency _curr, Decimal _amount) {
    return _trader.calculateFeeToUSD(_curr, _amount);
  }

  Decimal calculateFeeToFiat(Currency _curr, Decimal _amount) {
    return _trader.calculateFeeToUSD(_curr, _amount) /
        _selectedFiat.exchangeRate;
  }

  Future changeSelectedFiat(Fiat fiat) async {
    this._selectedFiat = fiat;
    await this._trader.setSelectedFiat(fiat);
  }
}
