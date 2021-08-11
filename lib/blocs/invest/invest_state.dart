part of 'invest_bloc.dart';

abstract class InvestState extends Equatable {
  const InvestState();

  @override
  List<Object> get props => [];
}

class InvestInitial extends InvestState {}

class ListInvestments extends InvestState {
  final List<InvestAccount>? investAccounts;

  ListInvestments({this.investAccounts});

  ListInvestments copyWith(
      {int? selectedType,
      List<Investment>? investments,
      int? showType,
      Decimal? totalRate}) {
    return ListInvestments(
        investAccounts: investAccounts ?? this.investAccounts);
  }

  @override
  List<Object> get props => [investAccounts!];
}
