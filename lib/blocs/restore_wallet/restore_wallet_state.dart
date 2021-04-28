part of 'restore_wallet_bloc.dart';

enum RESTORE_ERROR {
  PASSWORD,
  API,
  UNKNOWN
}
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

class PaperWallletRestoring extends RestoreWalletState {}

class PaperWalletRestored extends RestoreWalletState {}

class PaperWalletRestoreFail extends RestoreWalletState {
  final RESTORE_ERROR error;

  PaperWalletRestoreFail({this.error});
}