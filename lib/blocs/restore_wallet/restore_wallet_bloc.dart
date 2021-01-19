import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'restore_wallet_event.dart';
part 'restore_wallet_state.dart';

class RestoreWalletBloc extends Bloc<RestoreWalletEvent, RestoreWalletState> {
  RestoreWalletBloc() : super(RestoreWalletInitial());

  @override
  Stream<RestoreWalletState> mapEventToState(
    RestoreWalletEvent event,
  ) async* {
    if (event is GetPaperWallet) {
      yield PaperWalletSuccess(event.paperWallet);
    }
  }
}
