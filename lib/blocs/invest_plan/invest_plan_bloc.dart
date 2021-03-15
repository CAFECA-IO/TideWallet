import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

import '../../repositories/invest_repository.dart';

import '../../models/account.model.dart';
import '../../models/investment.model.dart';

import '../../helpers/logger.dart';

part 'invest_plan_event.dart';
part 'invest_plan_state.dart';

class InvestPlanBloc extends Bloc<InvestPlanEvent, InvestPlanState> {
  final InvestRepository _repo;

  InvestPlanBloc(
    this._repo,
  ) : super(InvestPlanInitial());

  @override
  Stream<InvestPlanState> mapEventToState(
    InvestPlanEvent event,
  ) async* {
    if (event is InvestPlanInitialed) {
      Decimal investAmount = Decimal.tryParse(event.currency.amount) ??
          Decimal.zero * Decimal.tryParse(event.percentage.value) ??
          Decimal.zero / Decimal.fromInt(100);
      Log.debug('event.currency.name: ${event.currency.name}');
      yield InvestPlanStatus(
          currency: event.currency,
          strategy: event.strategy,
          amplitude: event.amplitude,
          percentage: event.percentage,
          investAmount: investAmount);
    }

    if (state is InvestPlanStatus) {
      InvestPlanStatus _state = state;
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
        Decimal investAmount = Decimal.tryParse(_state.currency.amount) ??
            Decimal.zero * Decimal.tryParse(event.percentage.value) ??
            Decimal.zero / Decimal.fromInt(100);
        yield _state.copyWith(
            percentage: event.percentage, investAmount: investAmount);
      }
      if (event is CreateInvestPlan) {
        // TOOD
      }
    } else
      this.add(InvestPlanInitialed(
          null, InvestStrategy.Climb, InvestAmplitude.Normal, null));
  }
}
