part of 'fiat_bloc.dart';

abstract class FiatEvent extends Equatable {
  const FiatEvent();

  @override
  List<Object> get props => [];
}

class GetFiatList extends FiatEvent {}

class SwitchFiat extends FiatEvent {}