part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class ValidAddress extends TransactionEvent {
  final String address;
  ValidAddress(this.address);
}

class ValidAmount extends TransactionEvent {
  final String amount;
  ValidAmount(this.amount);
}

class ChangePriority extends TransactionEvent {
  final TransactionPriority priority;
  ChangePriority(this.priority);
}

class InputGasLimit extends TransactionEvent {
  final String gasLimit;
  InputGasLimit(this.gasLimit);
}

class InputGasPrice extends TransactionEvent {
  final String gasPrice;
  InputGasPrice(this.gasPrice);
}

class CreateTransaction extends TransactionEvent {}

class ConfirmTransaction extends TransactionEvent {
  final Function onConfirm;
  final Function onCancel;
  ConfirmTransaction(this.onConfirm, this.onCancel);
}
