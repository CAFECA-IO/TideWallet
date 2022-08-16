part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class UserCheck extends UserEvent {
  final bool debugMode;

  UserCheck({this.debugMode});
}

class UserCreate extends UserEvent {
  final String userIndentifier;

  UserCreate(this.userIndentifier);
}

class UserRestore extends UserEvent {}

class UserReset extends UserEvent {}
