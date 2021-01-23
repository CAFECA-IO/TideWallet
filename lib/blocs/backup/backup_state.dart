part of 'backup_bloc.dart';

abstract class BackupState extends Equatable {
  const BackupState();
  
  @override
  List<Object> get props => [];
}

class BackupInitial extends BackupState {}

class UnBackup extends BackupState {}

class Backuped extends BackupState {}