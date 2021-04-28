part of 'receive_bloc.dart';

abstract class ReceiveState extends Equatable {
  final Currency currency;
  final String address;
  const ReceiveState(this.currency, this.address);

  @override
  List<Object> get props => [];
}

class ReceiveInitial extends ReceiveState {
  ReceiveInitial(Currency currency, String address) : super(currency, address);

  @override
  List<Object> get props => [currency, address];
}

class AddressLoading extends ReceiveState {
  AddressLoading(Currency currency, String address) : super(currency, address);

  @override
  List<Object> get props => [currency, address];
}

class AddressLoaded extends ReceiveState {
  AddressLoaded(Currency currency, String address) : super(currency, address);

  @override
  List<Object> get props => [currency, address];
}
