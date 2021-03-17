import 'package:rxdart/rxdart.dart';
import 'package:decimal/decimal.dart';

import '../models/investment.model.dart';
import '../models/account.model.dart';

import '../helpers/utils.dart';

class InvestmentCore {
  PublishSubject<InvestmentMessage> messenger;
  List<InvestAccount> _investAccount = []; // --

  static final InvestmentCore _instance = InvestmentCore._internal();
  factory InvestmentCore() => _instance;

  InvestmentCore._internal();

  setMessenger() {
    messenger = PublishSubject<InvestmentMessage>();
  }

  Future<List<InvestAccount>> getInvestmentList(String usrId) async {
    // ++ fromDB 2021/3/16 Emily
    await Future.delayed(Duration(milliseconds: 500));

    return _investAccount;
  }

  Future<Investment> generateInvestment(
      Currency currency,
      InvestStrategy strategy,
      InvestAmplitude amplitude,
      Decimal amount) async {
    // ++ api: estimate profit, fee, id 2021/3/16 Emily
    String id = randomHex(6);
    String fee = '0.0003';
    String estimatedProfit = '102.125';
    String irr = '0.255';

    await Future.delayed(Duration(milliseconds: 500));

    return Investment(id, strategy, amplitude, amount, Decimal.parse(fee),
        Decimal.parse(estimatedProfit), Decimal.parse(irr));
  }

  Future<List> createInvestment(
      Currency currency, Investment investment) async {
    await Future.delayed(Duration(milliseconds: 500));
    // ++ api: post investment 2021/3/16 Emily
    int index =
        _investAccount.indexWhere((acc) => acc.currency.id == currency.id);
    if (index < 0)
      _investAccount.add(InvestAccount(currency, [investment])); // --
    else
      _investAccount[index].investments.add(investment);

    return [true, _investAccount];
  }
}
