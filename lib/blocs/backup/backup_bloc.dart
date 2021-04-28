import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tidewallet3/repositories/local_auth_repository.dart';

import '../../helpers/logger.dart';
import '../../repositories/user_repository.dart';
part 'backup_event.dart';
part 'backup_state.dart';

class BackupBloc extends Bloc<BackupEvent, BackupState> {
  UserRepository _repo;
  LocalAuthRepository _localAuthRepo = LocalAuthRepository();
  BackupBloc(this._repo) : super(BackupInitial());

  Future<bool> _capture(RenderRepaintBoundary boundary) async {
    final image = await boundary.toImage();
    ByteData byteData = await image.toByteData(format: ImageByteFormat.png);

    try {
      PermissionStatus status = await Permission.storage.request();

      if (status.isGranted) {
        final result = await ImageGallerySaver.saveImage(
            byteData.buffer.asUint8List(),
            name: "PaperWallet");
        Log.debug(result);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

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

    if (event is VerifyBackupPassword) {
      yield UnBackup();

      if (await (_localAuthRepo.authenticateUser())) {
        final wallet = await _repo.getPaperWallet();

        yield BackupAuth(wallet);
      } else {
        yield BackupDenied();

        await Future.delayed(Duration(milliseconds: 200));
        yield UnBackup();
      }
    }

    if (event is Backup) {
      yield Backuping();
      bool storeRes = await _capture(event.boundary);
      bool res = await _repo.backupWallet();

      if (res && storeRes) {
        yield Backuped();
      } else {
        yield BackupFail();

        await Future.delayed(Duration(milliseconds: 300));
        yield UnBackup();
      }
    }

    if (event is CleanBackup) {
      yield UnBackup();
    }
  }
}
