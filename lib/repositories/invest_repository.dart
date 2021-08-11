import 'package:decimal/decimal.dart';
import 'package:rxdart/subjects.dart';

import '../cores/investment.dart';
import '../models/account.model.dart';
import '../models/investment.model.dart';

class InvestRepository {
  PublishSubject<InvestmentMessage> get listener => InvestmentCore().messenger!;

  InvestRepository() {
    InvestmentCore().setMessenger();
  }

  Future<List<InvestAccount>> getInvestmentList(String usrId) async {
    return await InvestmentCore().getInvestmentList(usrId);
  }

  Future<Investment> generateInvestment(
      Currency currency,
      InvestStrategy strategy,
      InvestAmplitude amplitude,
      Decimal amount) async {
    return await InvestmentCore()
        .generateInvestment(currency, strategy, amplitude, amount);
  }

  Future<bool> createInvestment(
      Currency currency, Investment investment) async {
    List result = await InvestmentCore().createInvestment(currency, investment);
    if (result[0]) {
      InvestmentMessage invMsg = InvestmentMessage(
          evt: INVESTMENT_EVT.OnUpdateInvestment,
          value: {"investAccounts": result[1]});

      this.listener.add(invMsg);
    }

    return result[0];
  }
}
