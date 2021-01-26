
import '../models/account.model.dart';
import '../cores/trader.dart';

class TraderRepository {
  Trader _trader = Trader();
  
  Future<List<Fiat>> getFiatList() => _trader.getFiatList();

  Future<Fiat> getSelectedFiat() => _trader.getSelectedFiat();
}