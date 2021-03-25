part of 'local_auth_bloc.dart';

abstract class LocalAuthState extends Equatable {
  const LocalAuthState();

  @override
  List<Object> get props => [];
}

class LocalAuthInitial extends LocalAuthState {
  final bool isAuthenicated;
  LocalAuthInitial(this.isAuthenicated);
}

class AuthenticationStatus extends LocalAuthState {
  final bool isAuthenicated;
  AuthenticationStatus(this.isAuthenicated);

  @override
  List<Object> get props => [isAuthenicated];
}
