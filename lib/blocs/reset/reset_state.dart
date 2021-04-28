part of 'reset_bloc.dart';

enum RESET_ERROR {
  password,
  unknown
}

abstract class ResetState extends Equatable {
  const ResetState();
  
  @override
  List<Object> get props => [];
}

class ResetInitial extends ResetState {}

class ResetSuccess extends ResetState {}

class ResetError extends ResetState {
  final RESET_ERROR error;

  ResetError(this.error);

  @override
  List<Object> get props => [error];
}