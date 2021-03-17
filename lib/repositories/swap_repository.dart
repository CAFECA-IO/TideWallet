import '../models/transaction.model.dart';
import '../helpers/logger.dart';
import 'package:decimal/decimal.dart';

class SwapRepository {
  Map _rateTable = {};
  Map get rateTable => _rateTable;

  set setRateTable(Map t) {
    _rateTable = t;
  }

  Decimal calculateRate(String fromSymbol, String toSymbol) {
    String from = fromSymbol.toUpperCase();
    String to = toSymbol.toUpperCase();

    try {
      return Decimal.parse(_rateTable[from]) / Decimal.parse(_rateTable[to]);
    } catch (e) {
      Log.error('$e');
      return Decimal.zero;
    }
  }

  // TODO
  Decimal getFee() {
    return Decimal.parse('0.000005');
  }

  // TODO
  Future getRates() async {
    return Future.delayed(Duration(seconds: 1), () {
      return {
        'BTC': '11376.99993561',
        'ETH': '375.00938819',
        'USDT': '1.02',
        'DAI': '1.01'
      };
    });
  }
}
