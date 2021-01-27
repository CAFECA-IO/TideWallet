
import '../models/account.model.dart';
import '../cores/trader.dart';

class TraderRepository {
  Trader _trader = Trader();

  // Useless
  // Fiat _selectedFiat;
  // get selectedFiat => this._selectedFiat;
  // set setFiat(_fiat) => this._selectedFiat = _fiat;

  Future<List<Fiat>> getFiatList() => _trader.getFiatList();

  Future<Fiat> getSelectedFiat() => _trader.getSelectedFiat();
}