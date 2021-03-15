part of 'invest_plan_bloc.dart';

abstract class InvestPlanState extends Equatable {
  const InvestPlanState();

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
  final InvestPercentage percentage;
  final Decimal investAmount;
  InvestPlanStatus(
      {this.currency,
      this.strategy,
      this.amplitude,
      this.percentage,
      this.investAmount});

  InvestPlanState copyWith(
      {Currency currency,
      InvestStrategy strategy,
      InvestAmplitude amplitude,
      InvestPercentage percentage,
      Decimal investAmount}) {
    return InvestPlanStatus(
      currency: currency ?? this.currency,
      strategy: strategy ?? this.strategy,
      amplitude: amplitude ?? this.amplitude,
      percentage: percentage ?? this.percentage,
      investAmount: investAmount ?? this.investAmount,
    );
  }

  @override
  List<Object> get props =>
      [currency, strategy, amplitude, percentage, investAmount];
}
