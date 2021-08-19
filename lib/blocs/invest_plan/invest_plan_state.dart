part of 'invest_plan_bloc.dart';

abstract class InvestPlanState extends Equatable {
  final List<Account> accountList;
  const InvestPlanState(this.accountList);

  @override
  List<Object> get props => [this.accountList];
}

class InvestPlanInitial extends InvestPlanState {
  InvestPlanInitial(List<Account> accountList) : super(accountList);
}

class InvestLoading extends InvestPlanState {
  InvestLoading(List<Account> accountList) : super(accountList);
}

class InvestSuccess extends InvestPlanState {
  InvestSuccess(List<Account> accountList) : super(accountList);
}

class InvestFail extends InvestPlanState {
  InvestFail(List<Account> accountList) : super(accountList);
}

class InvestPlanStatus extends InvestPlanState {
  final List<Account> accountList;
  Account account;
  final InvestStrategy strategy;
  final InvestAmplitude amplitude;
  final InvestPercentage percentage;
  final Decimal investAmount;
  final Investment? investment;
  InvestPlanStatus(this.accountList,
      {required this.account,
      required this.strategy,
      required this.amplitude,
      required this.percentage,
      required this.investAmount,
      this.investment})
      : super(accountList);

  InvestPlanState copyWith(
      {Account? account,
      InvestStrategy? strategy,
      InvestAmplitude? amplitude,
      InvestPercentage? percentage,
      Decimal? investAmount,
      Investment? investment}) {
    return InvestPlanStatus(this.accountList,
        account: account ?? this.account,
        strategy: strategy ?? this.strategy,
        amplitude: amplitude ?? this.amplitude,
        percentage: percentage ?? this.percentage,
        investAmount: investAmount ?? this.investAmount,
        investment: investment ?? this.investment);
  }

  @override
  List<Object> get props => [
        accountList,
        account,
        strategy,
        amplitude,
        percentage,
        investAmount,
        investment!
      ];
}
