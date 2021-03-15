import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

import '../../repositories/invest_repository.dart';

import '../../models/account.model.dart';
import '../../models/investment.model.dart';

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
          Decimal.zero * Decimal.tryParse(event.percentage) ??
          Decimal.zero / Decimal.fromInt(100);
      yield InvestPlanStatus(
          currency: event.currency,
          strategy: event.strategy,
          amplitude: event.amplitude,
          investAmount: investAmount);
    }

    if (state is InvestPlanStatus) {
      InvestPlanStatus _state = state;
      if (event is CurrencySelected) {
        _state.copyWith(currency: event.currency);
      }
      if (event is StrategySetected) {
        _state.copyWith(strategy: event.strategy);
      }
      if (event is AmplitudeSelected) {
        _state.copyWith(amplitude: event.amplitude);
      }
      if (event is PercentageSelected) {
        Decimal investAmount = Decimal.tryParse(_state.currency.amount) ??
            Decimal.zero * Decimal.tryParse(event.percentage) ??
            Decimal.zero / Decimal.fromInt(100);
        _state.copyWith(investAmount: investAmount);
      }
      if (event is CreateInvestPlan) {
        // TOOD
      }
    } else
      this.add(InvestPlanInitialed(
          null, InvestStrategy.Climb, InvestAmplitude.Normal, null));
  }
}
