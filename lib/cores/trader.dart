import 'package:decimal/decimal.dart';

import '../mock/endpoint.dart';

import '../models/account.model.dart';

class Trader {
  List<Fiat> _fiats = [];
  List<Fiat> _cryptos = [];

  Future<List<Fiat>> getFiatList() async {
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

  Decimal calculateToUSD2(Currency _currency, Decimal amount) {
    int index = this._cryptos.indexWhere((c) => c.name == _currency.symbol);
    if (index < 0) return Decimal.zero;

    return this._cryptos[index].exchangeRate * amount;
  }
}
