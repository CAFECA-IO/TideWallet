part of 'fiat_bloc.dart';

abstract class FiatState extends Equatable {
  const FiatState();

  @override
  List<Object> get props => [];
}

class FiatInitial extends FiatState {}

class FiatLoaded extends FiatState {
  final List<Fiat> list;
  final Fiat fiat;

  FiatLoaded({required this.list, required this.fiat});

  copyWith({List<Fiat>? list, Fiat? fiat}) => FiatLoaded(
        fiat: fiat ?? this.fiat,
        list: list ?? this.list,
      );

  @override
  List<Object> get props => [fiat];
}
