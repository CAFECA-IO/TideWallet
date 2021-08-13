part of 'receive_bloc.dart';

abstract class ReceiveEvent extends Equatable {
  const ReceiveEvent();

  @override
  List<Object> get props => [];
}

class GetReceivingAddress extends ReceiveEvent {
  final Account account;
  GetReceivingAddress(this.account);

  @override
  List<Object> get props => [];
}
