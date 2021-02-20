import 'package:decimal/decimal.dart';

import '../database/entity/exchage_rate.dart';
import '../database/db_operator.dart';
import '../helpers/http_agent.dart';
import '../models/account.model.dart';
import '../constants/endpoint.dart';

class Trader {
  static const syncInterval = 24 * 60 * 60 * 1000;
  List<Fiat> _fiats = [];
  List<Fiat> _cryptos = [];

  Future<List<Fiat>> getFiatList() async {
    final local = await DBOperator().exchangeRateDao.findAllExchageRates();
    int now = DateTime.now().millisecondsSinceEpoch;

    if (local.isEmpty || now - local[0].lastSyncTime > syncInterval) {
      final rates = await Future.wait([
        HTTPAgent().get(Endpoint.SUSANOO + '/fiats/rate'),
        HTTPAgent().get(Endpoint.SUSANOO + '/crypto/rate'),
      ]);

      List fiats = rates[0].data;
      List cryptos = rates[1].data;

      await DBOperator().exchangeRateDao.insertExchangeRates([
        ...fiats.map(
          (e) => ExchangeRateEntity.fromJson(
            {...e, "timestamp": now, "type": "fiat"},
          ),
        ),
        ...cryptos.map(
          (e) => ExchangeRateEntity.fromJson(
            {...e, "timestamp": now, "type": "currency"},
          ),
        ),
      ]);

      this._fiats = fiats.map((r) => Fiat.fromMap(r)).toList();
      this._cryptos = cryptos.map((r) => Fiat.fromMap(r)).toList();
    } else {
      this._fiats = local
          .where((rate) => rate.type == 'fiat')
          .toList()
          .map((entity) => Fiat.fromExchangeRateEntity(entity))
          .toList();
      this._cryptos = local
          .where((rate) => rate.type != 'fiat')
          .toList()
          .map((entity) => Fiat.fromExchangeRateEntity(entity))
          .toList();
    }

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
