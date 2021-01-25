part of 'add_currency_bloc.dart';

abstract class AddCurrencyState extends Equatable {
  const AddCurrencyState();

  @override
  List<Object> get props => [];
}

class AddCurrencyInitial extends AddCurrencyState {}

class BeforeAdd extends AddCurrencyState {
  final bool loading;
  final String address;
  final bool valid;
  final Token result;

  BeforeAdd({this.loading, this.address, this.valid, this.result});

  copyWith({
    String address,
    bool loading,
    bool valid,
    Token result,
  }) =>
      BeforeAdd(
        address: address ?? this.address,
        loading: loading ?? this.loading,
        valid: valid ?? this.valid,
        result: result,
      );

  @override
  List<Object> get props => [loading, address, valid, result];
}

class AddSuccess extends AddCurrencyState {}

class AddFail extends AddCurrencyState {}
