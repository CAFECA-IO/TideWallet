import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

import '../../repositories/user_repository.dart';
import '../../cores/user.dart';

part 'restore_wallet_event.dart';
part 'restore_wallet_state.dart';

class RestoreWalletBloc extends Bloc<RestoreWalletEvent, RestoreWalletState> {
  UserRepository _repo;
  RestoreWalletBloc(this._repo) : super(RestoreWalletInitial());

  @override
  Stream<Transition<RestoreWalletEvent, RestoreWalletState>> transformEvents(
      Stream<RestoreWalletEvent> events, transitionFn) {
    return events
        .throttleTime(const Duration(milliseconds: 500))
        .switchMap((transitionFn));
  }

  @override
  Stream<RestoreWalletState> mapEventToState(
    RestoreWalletEvent event,
  ) async* {
    if (event is GetPaperWallet) {
      if (state is RestoreWalletInitial || state is PaperWalletFail) {
        if (_repo.validPaperWallet(event.paperWallet)) {
          yield PaperWalletSuccess(event.paperWallet);
        } else {
          yield PaperWalletFail();
        }
      }
    }

    if (event is CleanWalletResult) {
      yield RestoreWalletInitial();
    }

    if (event is RestorePapaerWallet) {
      PaperWalletSuccess _state = state;

      yield PaperWallletRestoring();
      final w =
          await _repo.restorePaperWallet(_state.paperWallet, event.password);
      if (w == null) {
        yield PaperWalletRestoreFail(error: RESTORE_ERROR.PASSWORD);

        this.add(CleanWalletResult());
      } else {
        User _user =
            await _repo.restoreUser(w, _state.paperWallet, event.password);
        if (_user == null) {
          yield PaperWalletRestoreFail();

          this.add(CleanWalletResult());
        } else {
          yield PaperWalletRestored();
        }
      }
    }
  }
}
