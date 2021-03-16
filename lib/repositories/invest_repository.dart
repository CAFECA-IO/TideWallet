import 'package:decimal/decimal.dart';
import 'package:rxdart/subjects.dart';

import '../cores/account.dart';
import '../models/account.model.dart';
import '../models/investment.model.dart';
import '../helpers/utils.dart';

class InvestRepository {
  PublishSubject<AccountMessage> get listener => AccountCore().messenger;
  List<InvestAccount> _investAccount = []; // --

  Future<List<InvestAccount>> getInvestmentList(String usrId) async {
    // ++ fromDB
    await Future.delayed(Duration(milliseconds: 500));

    return _investAccount;
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
    int index =
        _investAccount.indexWhere((acc) => acc.currency.id == currency.id);
    if (index < 0)
      _investAccount.add(InvestAccount(currency, [investment])); // --
    else
      _investAccount[index].investments.add(investment);

    AccountMessage invMsg = AccountMessage(
        evt: ACCOUNT_EVT.OnUpdateInvestment,
        value: {"investAccounts": _investAccount});

    this.listener.add(invMsg);
    return true;
  }
}
