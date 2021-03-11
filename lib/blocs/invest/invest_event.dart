part of 'invest_bloc.dart';

abstract class InvestEvent extends Equatable {
  const InvestEvent();

  @override
  List<Object> get props => [];
}

class GetInvest extends InvestEvent {
  final int type; // TODO

  GetInvest({this.type});
}

class ChangeShowType extends InvestEvent {
  final int type;

  ChangeShowType({this.type});
}

class UpdateTotalRate extends InvestEvent {}
