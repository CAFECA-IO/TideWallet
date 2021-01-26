import 'dart:async';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../repositories/user_repository.dart';
part 'backup_event.dart';
part 'backup_state.dart';

class BackupBloc extends Bloc<BackupEvent, BackupState> {
  UserRepository _repo;
  BackupBloc(this._repo) : super(BackupInitial());

  Future<bool> _capture(String wallet) async {
    final painter = QrPainter(
      data: wallet,
      version: QrVersions.auto,
      gapless: true,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );
    ByteData imageData;

    imageData = await painter.toImageData(600.0);
    final imageBytes = imageData.buffer.asUint8List();
    try {
      await ImageGallerySaver.saveImage(Uint8List.fromList(imageBytes),
          quality: 60, name: "Paper Wallet");

      return true;
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

      final wallet = 'wallet';
      if (true) {
        yield BackupAuth(wallet);
      } else {
        yield BackupDenied();

        await Future.delayed(Duration(milliseconds: 300));
        yield UnBackup();
      }
    }

    if (event is Backup) {
      BackupAuth _state = state;
      yield Backuping();
      await _capture(_state.wallet);
      bool res = await _repo.backupWallet();

      if (res) {
        yield Backuped();
      } else {
        yield BackupFail();

        await Future.delayed(Duration(milliseconds: 300));
        yield UnBackup();
      }
    }
  }
}
