part of 'invest_bloc.dart';

abstract class InvestEvent extends Equatable {
  const InvestEvent();

  @override
  List<Object> get props => [];
}

class UpdateInvestAccountList extends InvestEvent {
  final List<InvestAccount> investAccounts;

  UpdateInvestAccountList(this.investAccounts);
}

class GetInvestments extends InvestEvent {
  GetInvestments();
}
