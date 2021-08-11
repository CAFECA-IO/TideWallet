part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class UserCheck extends UserEvent {
  final bool? debugMode;

  UserCheck({this.debugMode});
}

class UserCreate extends UserEvent {
  final String userIndentifier;

  UserCreate(this.userIndentifier);
}

class UserInit extends UserEvent {
  UserInit();
}

class UserCreateWithSeed extends UserEvent {
  final String userIndentifier;
  final Uint8List seed;

  UserCreateWithSeed(this.userIndentifier, this.seed);
}

class UserReset extends UserEvent {}
