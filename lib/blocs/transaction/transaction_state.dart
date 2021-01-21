part of 'transaction_bloc.dart';

enum TransactionFormError {
  addressInvalid,
  amountInsufficient,
}

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionCheck extends TransactionState {
  final String address;
  final String amount;
  final TransactionPriority priority;
  final String gasLimit;
  final String gasPrice;
  final List<bool> rules;
  final TransactionFormError error;

  static const defaultValid = [false, false];

  TransactionCheck(
      {this.address = "",
      this.amount = "",
      this.priority = TransactionPriority.standard,
      this.gasLimit = "",
      this.gasPrice = "",
      this.rules = defaultValid,
      this.error});

  TransactionState copyWith({
    String address,
    String amount,
    TransactionPriority priority,
    String gasLimit,
    String gasPrice,
    List<bool> rules,
    TransactionFormError error,
  }) {
    return TransactionCheck(
      address: address ?? this.address,
      amount: amount ?? this.amount,
      priority: priority ?? this.priority,
      gasLimit: gasLimit ?? this.gasLimit,
      gasPrice: gasPrice ?? this.gasPrice,
      rules: rules ?? this.rules,
      error: error,
    );
  }

  @override
  List<Object> get props =>
      [address, amount, priority, gasLimit, gasPrice, rules, error];
}

class TransactionCheckSuccess extends TransactionState {
  final String address;
  final String amount;
  final TransactionPriority priority;
  final String gasLimit;
  final String gasPrice;

  TransactionCheckSuccess({
    this.address,
    this.amount,
    this.priority,
    this.gasLimit,
    this.gasPrice,
  });

  TransactionState copyWith({
    String address,
    String amount,
    TransactionPriority priority,
    String gasLimit,
    String gasPrice,
    List<bool> rules,
    TransactionFormError error,
  }) {
    return TransactionCheckSuccess(
        address: address ?? this.address,
        amount: amount ?? this.amount,
        priority: priority ?? this.priority,
        gasLimit: gasLimit ?? this.gasLimit,
        gasPrice: gasPrice ?? this.gasPrice);
  }

  @override
  List<Object> get props => [address, amount, priority, gasLimit, gasPrice];
}

class TransactionCheckFail extends TransactionState {}
