part of 'create_transaction_bloc.dart';

abstract class CreateTransactionState extends Equatable {
  const CreateTransactionState();
  
  @override
  List<Object> get props => [];
}

class CreateTransactionInitial extends CreateTransactionState {}
