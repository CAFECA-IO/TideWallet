part of 'toggle_token_bloc.dart';

abstract class ToggletokenEvent extends Equatable {
  const ToggletokenEvent();

  @override
  List<Object> get props => [];
}

class InitTokens extends ToggletokenEvent {
  const InitTokens();
}
