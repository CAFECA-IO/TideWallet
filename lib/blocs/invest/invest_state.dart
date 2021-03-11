part of 'invest_bloc.dart';

abstract class InvestState extends Equatable {
  const InvestState();

  @override
  List<Object> get props => [];
}

class InvestInitial extends InvestState {}

class InvestListSucccess extends InvestState {
  final int selectedType; // For filter investment product type,
  final List<Investment> investments;
  final int showType;
  final Decimal totalRate;

  InvestListSucccess(
      {this.selectedType, this.investments, this.showType: 0, this.totalRate});

  InvestListSucccess copyWith(
      {int selectedType,
      List<Investment> investments,
      int showType,
      Decimal totalRate}) {
    return InvestListSucccess(
      investments: investments ?? this.investments,
      selectedType: selectedType ?? this.selectedType,
      showType: showType ?? this.showType,
      totalRate: totalRate ?? this.totalRate,
    );
  }

  @override
  List<Object> get props => [totalRate, investments, selectedType];
}
