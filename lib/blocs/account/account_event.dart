part of 'account_bloc.dart';

@immutable
abstract class AccountEvent extends Equatable {}

// class GetAccount extends AccountEvent {
//   @override
//   List<Object> get props => [];

// }

class UpdateAccount extends AccountEvent {
  final Currency account;

  UpdateAccount(this.account);

  @override
  List<Object> get props => [];

}