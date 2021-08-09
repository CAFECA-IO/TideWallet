part of 'invest_plan_bloc.dart';

abstract class InvestPlanState extends Equatable {
  const InvestPlanState();

  @override
  List<Object> get props => [];
}

class InvestPlanInitial extends InvestPlanState {
  InvestPlanInitial();
}

class InvestLoading extends InvestPlanState {
  InvestLoading();
}

class InvestSuccess extends InvestPlanState {
  InvestSuccess();
}

class InvestFail extends InvestPlanState {
  InvestFail();
}

class InvestPlanStatus extends InvestPlanState {
  Currency currency;
  final InvestStrategy strategy;
  final InvestAmplitude amplitude;
  final InvestPercentage percentage;
  final Decimal investAmount;
  final Investment? investment;
  InvestPlanStatus(
      {required this.currency,
      required this.strategy,
      required this.amplitude,
      required this.percentage,
      required this.investAmount,
      this.investment});

  InvestPlanState copyWith(
      {Currency? currency,
      InvestStrategy? strategy,
      InvestAmplitude? amplitude,
      InvestPercentage? percentage,
      Decimal? investAmount,
      Investment? investment}) {
    return InvestPlanStatus(
        currency: currency ?? this.currency,
        strategy: strategy ?? this.strategy,
        amplitude: amplitude ?? this.amplitude,
        percentage: percentage ?? this.percentage,
        investAmount: investAmount ?? this.investAmount,
        investment: investment ?? this.investment);
  }

  @override
  List<Object> get props =>
      [currency, strategy, amplitude, percentage, investAmount, investment!];
}
