part of 'toggle_token_bloc.dart';

abstract class ToggleTokenState extends Equatable {
  const ToggleTokenState();

  @override
  List<Object> get props => [];
}

class ToggleTokenInitial extends ToggleTokenState {}

class ToggleTokenLoaded extends ToggleTokenState {
  final List<DisplayCurrency> list;

  ToggleTokenLoaded(this.list);

  ToggleTokenLoaded copyWith(List<DisplayCurrency> list) =>
      ToggleTokenLoaded(this.list);

  @override
  List<Object> get props => [List];
}
