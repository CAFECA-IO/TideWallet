import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../repositories/account_repository.dart';
import '../../repositories/user_repository.dart';

part 'reset_event.dart';
part 'reset_state.dart';

class ResetBloc extends Bloc<ResetEvent, ResetState> {
  ResetBloc(this._userRepo, this._accountRepository) : super(ResetInitial());
  UserRepository _userRepo;
  AccountRepository _accountRepository;

  @override
  Stream<ResetState> mapEventToState(
    ResetEvent event,
  ) async* {
    if (event is ResetWallet) {
      yield ResetInitial();
      final verified = _userRepo.verifyPassword(event.password);

      if (!verified) {
        yield ResetError(RESET_ERROR.password);
      } else {
        _accountRepository.close();
        final success = await _userRepo.deleteUser();

        if (success) {
          yield ResetSuccess();
        } else {
          _accountRepository.coreInit();

          yield ResetError(RESET_ERROR.unknown);
        }
      }
    }
  }
}
