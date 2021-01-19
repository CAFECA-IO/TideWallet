part of 'restore_wallet_bloc.dart';

abstract class RestoreWalletEvent extends Equatable {
  const RestoreWalletEvent();

  @override
  List<Object> get props => [];
}

class GetPaperWallet extends RestoreWalletEvent {
  final String paperWallet;

  GetPaperWallet(this.paperWallet);
}