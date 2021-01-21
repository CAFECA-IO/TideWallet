import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import '../../repositories/account_repository.dart';
import '../../models/account.model.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountRepository _repo;
  StreamSubscription _subscription;
  AccountBloc(
    this._repo
  ) : super(AccountInitial()) {
    _subscription?.cancel();
    this._repo.listener.listen((msg) {
      if (msg.evt == ACCOUNT_EVT.OnUpdateAccount) {
        this.add(UpdateAccount(msg.value));
      }
    });

    this._repo.coreInit();
  }

  @override
  Future<void> close() {
    _repo.listener.close();
    return super.close();
  }

  @override
  Stream<AccountState> mapEventToState(
    AccountEvent event,
  ) async* {
    if (event is UpdateAccount) {
      
      AccountState _state = state;

      int index = _state.accounts.indexWhere((account) => account.name == event.account.name);
      List<Account> _accounts = [..._state.accounts];
      if (index < 0) {
        _accounts.add(event.account);
      } else {
        _accounts[index] = event.account;
      }
      yield AccountLoaded(_accounts);
    }
  }
}
