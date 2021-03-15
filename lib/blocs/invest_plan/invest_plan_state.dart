part of 'invest_plan_bloc.dart';

abstract class InvestPlanState extends Equatable {
  Currency currency;
  InvestStrategy strategy;
  InvestAmplitude amplitude;
  Decimal investAmount;
  InvestPlanState();

  @override
  List<Object> get props => [];
}

class InvestPlanInitial extends InvestPlanState {
  InvestPlanInitial();
}

class InvestPlanStatus extends InvestPlanState {
  Currency currency;
  final InvestStrategy strategy;
  final InvestAmplitude amplitude;
  final Decimal investAmount;
  InvestPlanStatus(
      {this.currency, this.strategy, this.amplitude, this.investAmount});

  InvestPlanState copyWith(
      {Currency currency,
      InvestStrategy strategy,
      InvestAmplitude amplitude,
      Decimal investAmount}) {
    return InvestPlanStatus(
      currency: currency ?? this.currency,
      strategy: strategy ?? this.strategy,
      amplitude: amplitude ?? this.amplitude,
      investAmount: investAmount ?? this.investAmount,
    );
  }

  @override
  List<Object> get props => [currency, strategy, amplitude, investAmount];
}
