part of 'backup_bloc.dart';

abstract class BackupEvent extends Equatable {
  const BackupEvent();

  @override
  List<Object> get props => [];
}

class CheckBackup extends BackupEvent {}

class VerifyBackupPassword extends BackupEvent {
  final String password;

  VerifyBackupPassword(this.password);
}

class Backup extends BackupEvent {}