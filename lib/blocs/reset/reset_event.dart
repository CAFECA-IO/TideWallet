part of 'reset_bloc.dart';

abstract class ResetEvent extends Equatable {
  const ResetEvent();

  @override
  List<Object> get props => [];
}

class ResetWallet extends ResetEvent {
  // final String password;

  // ResetWallet(this.password);
  ResetWallet();
}
