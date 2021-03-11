part of 'invest_bloc.dart';

abstract class InvestEvent extends Equatable {
  const InvestEvent();

  @override
  List<Object> get props => [];
}

class GetInvestments extends InvestEvent {
  GetInvestments();
}
