part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class UpdateTransactionCreateCurrency extends TransactionEvent {
  final Currency currency;
  UpdateTransactionCreateCurrency(this.currency);
}

class ResetAddress extends TransactionEvent {
  ResetAddress();
}

class ScanQRCode extends TransactionEvent {
  final String address;
  ScanQRCode(this.address);
}

class ValidAddress extends TransactionEvent {
  final String address;
  ValidAddress(this.address);
}

class VerifyAmount extends TransactionEvent {
  final String amount;

  VerifyAmount(this.amount);
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

class PrepareTransaction extends TransactionEvent {
  final String address;
  final String amount;
  PrepareTransaction(this.address, this.amount);
}

class PublishTransaction extends TransactionEvent {
  PublishTransaction();
}
