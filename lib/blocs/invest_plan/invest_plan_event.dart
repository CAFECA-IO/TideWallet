part of 'invest_plan_bloc.dart';

abstract class InvestPlanEvent extends Equatable {
  const InvestPlanEvent();

  @override
  List<Object> get props => [];
}

class InvestPlanInitialed extends InvestPlanEvent {
  final Currency currency;
  final InvestStrategy strategy;
  final InvestAmplitude amplitude;
  final InvestPercentage percentage;
  InvestPlanInitialed(
      this.currency, this.strategy, this.amplitude, this.percentage);
}

class CurrencySelected extends InvestPlanEvent {
  final Currency currency;
  CurrencySelected(this.currency);
}

class StrategySetected extends InvestPlanEvent {
  final InvestStrategy strategy;
  StrategySetected(this.strategy);
}

class AmplitudeSelected extends InvestPlanEvent {
  final InvestAmplitude amplitude;
  AmplitudeSelected(this.amplitude);
}

class PercentageSelected extends InvestPlanEvent {
  final InvestPercentage percentage;
  PercentageSelected(this.percentage);
}

class InputPercentage extends InvestPlanEvent {
  final String percentage;
  InputPercentage(this.percentage);
}

class GenerateInvestPlan extends InvestPlanEvent {}

class CreateInvestPlan extends InvestPlanEvent {
  final String password;
  CreateInvestPlan(this.password);
}
