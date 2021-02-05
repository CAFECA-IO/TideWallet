part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class UserCheck extends UserEvent {}

class UserCreate extends UserEvent {
  final String password;

  UserCreate(this.password);
}

class UserRestore extends UserEvent {}

class VerifyPassword extends UserEvent {
  final String password;
  VerifyPassword(this.password);
}

class UpdatePassword extends UserEvent {
  final String password;
  UpdatePassword(this.password);
}
