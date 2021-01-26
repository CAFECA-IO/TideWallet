part of 'receive_bloc.dart';

abstract class ReceiveEvent extends Equatable {
  const ReceiveEvent();

  @override
  List<Object> get props => [];
}

class GetReceivingAddress extends ReceiveEvent {
  final Currency currency;
  GetReceivingAddress(this.currency);

  @override
  List<Object> get props => [];
}
