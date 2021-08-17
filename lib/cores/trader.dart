import 'package:decimal/decimal.dart';

import '../database/entity/exchage_rate.dart';
import '../database/db_operator.dart';
import '../helpers/http_agent.dart';
import '../models/account.model.dart';
import '../constants/endpoint.dart';
import '../helpers/prefer_manager.dart';

class Trader {
  static const syncInterval = 24 * 60 * 60 * 1000;
  List<Fiat> _fiats = [];
  List<Fiat> _cryptos = [];
  PrefManager _prefManager = PrefManager();

  Future<List<Fiat>> getFiatList() async {
    final local = await DBOperator().exchangeRateDao.findAllExchageRates();
    int now = DateTime.now().millisecondsSinceEpoch;

    if (local.isEmpty || now - local[0].lastSyncTime > syncInterval) {
      final rates = await Future.wait([
        HTTPAgent().get(Endpoint.url + '/fiats/rate'),
        HTTPAgent().get(Endpoint.url + '/crypto/rate'),
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

  Future setSelectedFiat(Fiat fiat) =>
      this._prefManager.setSelectedFiat(fiat.name);

  Future<Fiat> getSelectedFiat() async {
    String? symbol = await this._prefManager.getSeletedFiat();

    if (symbol == null) return this._fiats[0];

    int index = this._fiats.indexWhere((f) => f.name == symbol);

    return this._fiats[index];
  }

  Decimal calculateToFiat(Account _account, Fiat fiat) {
    int index =
        this._cryptos.indexWhere((c) => c.currencyId == _account.currencyId);
    if (index < 0) return Decimal.zero;

    return this._cryptos[index].exchangeRate *
        Decimal.tryParse(_account.balance)! *
        fiat.exchangeRate;
  }

  Decimal calculateToUSD(Account _account) {
    int index =
        this._cryptos.indexWhere((c) => c.currencyId == _account.currencyId);
    if (index < 0) return Decimal.zero;

    return this._cryptos[index].exchangeRate *
        Decimal.tryParse(_account.balance)!;
  }

  Decimal calculateUSDToCurrency(Account _account, Decimal amountInUSD) {
    int index =
        this._cryptos.indexWhere((c) => c.currencyId == _account.currencyId);
    if (index < 0) return Decimal.zero;

    return amountInUSD / this._cryptos[index].exchangeRate;
  }

  Decimal calculateAmountToUSD(Account _account, Decimal amount) {
    int index =
        this._cryptos.indexWhere((c) => c.currencyId == _account.currencyId);
    if (index < 0) return Decimal.zero;
    return this._cryptos[index].exchangeRate * amount;
  }

  Map<String, Decimal> getSwapRateAndAmount(
      Account sellAccount, Account buyAccount, Decimal sellAmount) {
    Fiat sellCryptos =
        this._cryptos.firstWhere((c) => c.currencyId == sellAccount.currencyId);
    Fiat buyCryptos =
        this._cryptos.firstWhere((c) => c.currencyId == buyAccount.currencyId);
    // Log.debug(
    //     'sellCryptos ${sellCryptos.name} [${sellCryptos.currencyId}]: ${sellCryptos.exchangeRate}');
    // Log.debug(
    //     'buyCryptos ${buyCryptos.name} [${buyCryptos.currencyId}]: ${buyCryptos.exchangeRate}');
    Decimal exchangeRate = calculateUSDToCurrency(
        buyAccount, calculateAmountToUSD(sellAccount, Decimal.one));
    Decimal buyAmount =
        calculateUSDToCurrency(buyAccount, sellAmount * exchangeRate);
    return {"buyAmount": buyAmount, "exchangeRate": exchangeRate};
  }
}
