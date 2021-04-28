part of 'backup_bloc.dart';

abstract class BackupState extends Equatable {
  const BackupState();
  
  @override
  List<Object> get props => [];
}

class BackupInitial extends BackupState {}

class UnBackup extends BackupState {}

class BackupDenied extends BackupState {}

class BackupAuth extends BackupState {
  final String wallet;

  BackupAuth(this.wallet);
}

class Backuping extends BackupState {}

class Backuped extends BackupState {}

class BackupFail extends BackupState {}