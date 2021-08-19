import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

import '../../repositories/trader_repository.dart';
import '../../repositories/invest_repository.dart';
import '../../repositories/account_repository.dart';

import '../../models/account.model.dart';
import '../../models/investment.model.dart';

import '../../helpers/logger.dart';

part 'invest_plan_event.dart';
part 'invest_plan_state.dart';

class InvestPlanBloc extends Bloc<InvestPlanEvent, InvestPlanState> {
  final InvestRepository _repo;
  final AccountRepository _accountRepo;
  final TraderRepository _traderRepo;

  InvestPlanBloc(this._repo, this._accountRepo, this._traderRepo)
      : super(InvestPlanInitial(_accountRepo.accountList));

  @override
  Stream<Transition<InvestPlanEvent, InvestPlanState>> transformEvents(
      Stream<InvestPlanEvent> events, transitionFn) {
    final nonDebounceStream =
        events.where((event) => event is! InputPercentage);

    final debounceStream = events
        .where((event) => event is InputPercentage)
        .debounceTime(Duration(milliseconds: 1000));

    return super.transformEvents(
        MergeStream([nonDebounceStream, debounceStream]), transitionFn);
  }

  @override
  Stream<InvestPlanState> mapEventToState(
    InvestPlanEvent event,
  ) async* {
    if (event is InvestPlanInitialed) {
      late Account account;
      if (event.account != null)
        account = event.account!;
      else
        account = _accountRepo.accountMap[0]![0];

      Decimal investAmount = Decimal.tryParse(account.balance) ??
          Decimal.zero * Decimal.tryParse(event.percentage.value)!;
      Log.debug('account.name: ${account.name}');
      yield InvestPlanStatus(_accountRepo.accountList,
          account: account,
          strategy: event.strategy,
          amplitude: event.amplitude,
          percentage: event.percentage,
          investAmount: investAmount);
    }

    if (state is InvestPlanStatus) {
      InvestPlanStatus _state = state as InvestPlanStatus;
      if (event is AccountSelected) {
        yield _state.copyWith(account: event.account);
      }
      if (event is StrategySetected) {
        yield _state.copyWith(strategy: event.strategy);
      }
      if (event is AmplitudeSelected) {
        yield _state.copyWith(amplitude: event.amplitude);
      }
      if (event is PercentageSelected) {
        Decimal investAmount = Decimal.tryParse(_state.account.balance) ??
            Decimal.zero * Decimal.tryParse(event.percentage.value)!;
        yield _state.copyWith(
            percentage: event.percentage, investAmount: investAmount
            // _traderRepo.calculateAmountToFiat(_state.account, investAmount)
            );
      }
      if (event is InputPercentage) {
        Decimal investAmount = Decimal.tryParse(_state.account.balance) ??
            Decimal.zero * Decimal.tryParse(event.percentage)!;
        yield _state.copyWith(investAmount: investAmount
            // _traderRepo.calculateAmountToFiat(_state.account, investAmount)
            );
      }
      if (event is GenerateInvestPlan) {
        // TOOD
        yield InvestLoading(_accountRepo.accountList);
        Investment investment = await _repo.generateInvestment(_state.account,
            _state.strategy, _state.amplitude, _state.investAmount);
        investment.feeToFiat =
            _traderRepo.calculateAmountToFiat(_state.account, investment.fee);
        yield _state.copyWith(investment: investment);
      }
      if (event is CreateInvestPlan) {
        // TOOD
        yield InvestLoading(_accountRepo.accountList);
        bool result =
            await _repo.createInvestment(_state.account, _state.investment!);
        if (result)
          yield InvestSuccess(_accountRepo.accountList);
        else
          yield InvestFail(_accountRepo.accountList);
      }
    } else
      this.add(InvestPlanInitialed(
          account: _accountRepo.accountMap[0]![0],
          strategy: InvestStrategy.Climb,
          amplitude: InvestAmplitude.Normal,
          percentage: InvestPercentage.Low));
  }
}
