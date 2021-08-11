import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

import '../../cores/account.dart';

import '../../repositories/trader_repository.dart';
import '../../repositories/invest_repository.dart';

import '../../models/account.model.dart';
import '../../models/investment.model.dart';

import '../../helpers/logger.dart';

part 'invest_plan_event.dart';
part 'invest_plan_state.dart';

class InvestPlanBloc extends Bloc<InvestPlanEvent, InvestPlanState> {
  final InvestRepository _repo;
  final TraderRepository _traderRepo;

  InvestPlanBloc(this._repo, this._traderRepo) : super(InvestPlanInitial());

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
      Decimal investAmount = Decimal.tryParse(event.currency.amount!) ??
          Decimal.zero * Decimal.tryParse(event.percentage.value)!;
      Log.debug('event.currency.name: ${event.currency.name}');
      yield InvestPlanStatus(
          currency: event.currency,
          strategy: event.strategy,
          amplitude: event.amplitude,
          percentage: event.percentage,
          investAmount: investAmount);
    }

    if (state is InvestPlanStatus) {
      InvestPlanStatus _state = state as InvestPlanStatus;
      if (event is CurrencySelected) {
        yield _state.copyWith(currency: event.currency);
      }
      if (event is StrategySetected) {
        yield _state.copyWith(strategy: event.strategy);
      }
      if (event is AmplitudeSelected) {
        yield _state.copyWith(amplitude: event.amplitude);
      }
      if (event is PercentageSelected) {
        Decimal investAmount = Decimal.tryParse(_state.currency.amount!) ??
            Decimal.zero * Decimal.tryParse(event.percentage.value)!;
        yield _state.copyWith(
            percentage: event.percentage, investAmount: investAmount
            // _traderRepo.calculateAmountToFiat(_state.currency, investAmount)
            );
      }
      if (event is InputPercentage) {
        Decimal investAmount = Decimal.tryParse(_state.currency.amount!) ??
            Decimal.zero * Decimal.tryParse(event.percentage)!;
        yield _state.copyWith(investAmount: investAmount
            // _traderRepo.calculateAmountToFiat(_state.currency, investAmount)
            );
      }
      if (event is GenerateInvestPlan) {
        // TOOD
        yield InvestLoading();
        Investment investment = await _repo.generateInvestment(_state.currency,
            _state.strategy, _state.amplitude, _state.investAmount);
        investment.feeToFiat =
            _traderRepo.calculateAmountToFiat(_state.currency, investment.fee);
        yield _state.copyWith(investment: investment);
      }
      if (event is CreateInvestPlan) {
        // TOOD
        yield InvestLoading();
        bool result =
            await _repo.createInvestment(_state.currency, _state.investment!);
        if (result)
          yield InvestSuccess();
        else
          yield InvestFail();
      }
    } else
      this.add(InvestPlanInitialed(AccountCore().accounts[0],
          InvestStrategy.Climb, InvestAmplitude.Normal, InvestPercentage.Low));
  }
}
