part of 'receive_bloc.dart';

abstract class ReceiveState extends Equatable {
  final Account? account;
  final String? address;
  const ReceiveState(this.account, this.address);

  @override
  List<Object> get props => [];
}

class ReceiveInitial extends ReceiveState {
  ReceiveInitial(Account? account, String? address) : super(account, address);

  @override
  List<Object> get props => [account!, address!];
}

class AddressLoading extends ReceiveState {
  AddressLoading(Account account, String address) : super(account, address);

  @override
  List<Object> get props => [account!, address!];
}

class AddressLoaded extends ReceiveState {
  AddressLoaded(Account account, String address) : super(account, address);

  @override
  List<Object> get props => [account!, address!];
}
