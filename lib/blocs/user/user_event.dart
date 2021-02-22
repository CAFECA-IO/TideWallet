part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class UserCheck extends UserEvent {}

class UserCreate extends UserEvent {
  final String password;
  final String walletName;

  UserCreate(this.password, this.walletName);
}

class UserRestore extends UserEvent {}

class VerifyPassword extends UserEvent {
  final String password;
  VerifyPassword(this.password);
}

