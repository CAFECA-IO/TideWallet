part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class ScanQRCode extends TransactionEvent {
  final String address;
  ScanQRCode(this.address);
}

class ValidAddress extends TransactionEvent {
  final String address;
  ValidAddress(this.address);
}

class ValidAmount extends TransactionEvent {
  final String amount;
  ValidAmount(this.amount);
}

class FetchTransactionFee extends TransactionEvent {
  FetchTransactionFee();
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

class CreateTransaction extends TransactionEvent {
  CreateTransaction();
}
