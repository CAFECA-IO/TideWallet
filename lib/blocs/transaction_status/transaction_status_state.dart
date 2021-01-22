part of 'transaction_status_bloc.dart';

abstract class TransactionStatusState extends Equatable {
  const TransactionStatusState();
  
  @override
  List<Object> get props => [];
}

class TransactionStatusInitial extends TransactionStatusState {}
