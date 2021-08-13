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
      Account account,
      InvestStrategy strategy,
      InvestAmplitude amplitude,
      Decimal amount) async {
    return await InvestmentCore()
        .generateInvestment(account, strategy, amplitude, amount);
  }

  Future<bool> createInvestment(Account account, Investment investment) async {
    List result = await InvestmentCore().createInvestment(account, investment);
    if (result[0]) {
      InvestmentMessage invMsg = InvestmentMessage(
          evt: INVESTMENT_EVT.OnUpdateInvestment,
          value: {"investAccounts": result[1]});

      this.listener.add(invMsg);
    }

    return result[0];
  }
}
