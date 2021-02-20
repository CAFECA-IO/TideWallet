import 'package:decimal/decimal.dart';
// import 'package:tidewallet3/database/db_operator.dart';

import '../mock/endpoint.dart';

import '../models/account.model.dart';

class Trader {
  static const syncInterval = 24 * 60 * 60 * 1000;
  List<Fiat> _fiats = [];
  List<Fiat> _cryptos = [];

  Future<List<Fiat>> getFiatList() async {
    // final local = await DBOperator().currencyDao.findAllExchageRates();
    // int now = DateTime.now().millisecondsSinceEpoch;

    // if (local.isEmpty || now - local[0].lastSyncTime > syncInterval) {

    // } else {
    //   this._fiats = 
    // }
    final result = await exchangeRate();

    this._fiats = result['fiat'].map((e) => Fiat.fromMap(e)).toList();
    this._cryptos = result['crypto'].map((e) => Fiat.fromMap(e)).toList();

    return this._fiats;
  }

  Future<Fiat> getSelectedFiat() async {
    await Future.delayed(Duration(milliseconds: 300));

    return null;
  }

  Decimal calculateToUSD(Currency _currency) {
    int index = this._cryptos.indexWhere((c) => c.name == _currency.symbol);
    if (index < 0) return Decimal.zero;

    return this._cryptos[index].exchangeRate *
        Decimal.tryParse(_currency.amount);
  }

  Decimal calculateFeeToUSD(Currency _currency, Decimal amount) {
    int index = this._cryptos.indexWhere((c) => c.name == _currency.symbol);
    if (index < 0) return Decimal.zero;

    return this._cryptos[index].exchangeRate * amount;
  }
}
