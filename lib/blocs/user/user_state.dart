part of 'user_bloc.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserExist extends UserState {
  final bool existed;
  UserExist(this.existed);
}

class UserFail extends UserState {}

class UserAuthenticated extends UserState {}
