part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class UserCreate extends UserEvent {}

class UserRestore extends UserEvent {}

class VerifyPassword extends UserEvent {
  final String password;
  VerifyPassword(this.password);
}

class UpdatePassword extends UserEvent {
  final String password;
  UpdatePassword(this.password);
}
