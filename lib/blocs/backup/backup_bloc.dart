import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../repositories/user_repository.dart';
part 'backup_event.dart';
part 'backup_state.dart';

class BackupBloc extends Bloc<BackupEvent, BackupState> {
  UserRepository _repo;
  BackupBloc(this._repo) : super(BackupInitial());

  @override
  Stream<BackupState> mapEventToState(
    BackupEvent event,
  ) async* {
    if (event is CheckBackup) {
      bool backup = await _repo.checkWalletBackup();

      if (backup) {
        yield Backuped();
      } else {
        yield UnBackup();
      }
    }
  }
}
