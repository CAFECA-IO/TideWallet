part of 'restore_wallet_bloc.dart';

abstract class RestoreWalletState extends Equatable {
  const RestoreWalletState();
  
  @override
  List<Object> get props => [];
}

class RestoreWalletInitial extends RestoreWalletState {}

class PaperWalletSuccess extends RestoreWalletState {
  final String paperWallet;

  PaperWalletSuccess(this.paperWallet);

    
  @override
  List<Object> get props => [paperWallet];
}

class PaperWalletFail extends RestoreWalletState {}