import 'package:decimal/decimal.dart';

import '../models/account.model.dart';
import '../models/investment.model.dart';
import '../helpers/utils.dart';

class InvestRepository {
  Future<List<InvestAccount>> getInvestmentList(String usrId) async {
    // TODO fetch

    return [];
  }

  Future<Investment> generateInvestment(
      Currency currency,
      InvestStrategy strategy,
      InvestAmplitude amplitude,
      Decimal amount) async {
    // ++ api: estimate profit, fee, id
    String id = randomHex(6);
    String fee = '0.0003';
    String estimatedProfit = '102.125';
    String irr = '0.255';

    await Future.delayed(Duration(milliseconds: 500));

    return Investment(id, strategy, amplitude, amount, Decimal.parse(fee),
        Decimal.parse(estimatedProfit), Decimal.parse(irr));
  }

  Future<bool> createInvestment(
      Currency currency, Investment investment) async {
    await Future.delayed(Duration(milliseconds: 500));
    // ++ api: post investment
    // in
    return true;
  }
}
