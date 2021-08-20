part of 'receive_bloc.dart';

abstract class ReceiveState extends Equatable {
  final Account? account;
  final String address;
  const ReceiveState(this.account, this.address);
  @override
  List<Object> get props => [];
}

class ReceiveInitial extends ReceiveState {
  ReceiveInitial() : super(null, '');
}

class AddressLoading extends ReceiveState {
  final Account account;
  AddressLoading(Account account)
      : this.account = account,
        super(account, '');
  @override
  List<Object> get props => [account];
}

class AddressLoaded extends ReceiveState {
  final Account account;

  AddressLoaded(Account account, String address)
      : this.account = account,
        super(account, address);
  @override
  List<Object> get props => [account, address];
}
