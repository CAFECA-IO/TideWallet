part of 'transaction_bloc.dart';

enum TransactionFormError { addressInvalid, amountInsufficient, none }

abstract class TransactionState extends Equatable {
  final Account? account;
  const TransactionState(this.account);

  @override
  List<Object> get props => [];
}

class TransactionPrepare extends TransactionState {
  TransactionPrepare() : super(null);
}

class TransactionInitial extends TransactionState {
  final Account account;
  final String? address;
  final Decimal? amount;
  final Decimal? spandable;
  final TransactionPriority priority;
  final Decimal? gasLimit;
  final Decimal? gasPrice;
  final Decimal? fee;
  final String feeToFiat;
  final String estimatedTime;
  final List<bool> rules;
  final TransactionFormError error;
  final String? message;

  static const defaultValid = [false, false];

  TransactionInitial(Account account,
      {this.address,
      this.amount,
      this.spandable,
      this.priority = TransactionPriority.standard,
      this.gasLimit,
      this.gasPrice,
      this.fee,
      this.feeToFiat = "loading...",
      this.estimatedTime = "10~30",
      this.rules = defaultValid,
      this.error = TransactionFormError.none,
      this.message})
      : this.account = account,
        super(account);

  TransactionState copyWith({
    String? address,
    Decimal? amount,
    Decimal? spandable,
    TransactionPriority? priority,
    Decimal? gasLimit,
    Decimal? gasPrice,
    Decimal? fee,
    String? feeToFiat,
    String? estimatedTime,
    List<bool>? rules,
    TransactionFormError? error,
    String? message,
  }) {
    return TransactionInitial(this.account,
        address: address ?? this.address,
        amount: amount ?? this.amount,
        spandable: spandable ?? this.spandable,
        priority: priority ?? this.priority,
        gasLimit: gasLimit ?? this.gasLimit,
        gasPrice: gasPrice ?? this.gasPrice,
        fee: fee ?? this.fee,
        feeToFiat: feeToFiat ?? this.feeToFiat,
        estimatedTime: estimatedTime ?? this.estimatedTime,
        rules: rules ?? this.rules,
        error: error ?? this.error,
        message: message ?? this.message);
  }

  @override
  List<Object> get props => [
        address!,
        amount!,
        spandable!,
        priority,
        gasLimit!,
        gasPrice!,
        fee!,
        feeToFiat,
        estimatedTime,
        rules,
        error,
        message!
      ];
}

class CreateTransactionFail extends TransactionState {
  CreateTransactionFail() : super(null);
}

class TransactionSent extends TransactionState {
  TransactionSent() : super(null);
}

class TransactionPublishing extends TransactionState {
  TransactionPublishing() : super(null);
}
