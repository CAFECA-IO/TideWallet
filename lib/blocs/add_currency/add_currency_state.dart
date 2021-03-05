part of 'add_currency_bloc.dart';

abstract class AddCurrencyState extends Equatable {
  const AddCurrencyState();

  @override
  List<Object> get props => [];
}

class AddCurrencyInitial extends AddCurrencyState {}

class BeforeAdd extends AddCurrencyState {
  final String address;
  final bool valid;

  BeforeAdd({this.address, this.valid});

  copyWith({
    String address,
    bool valid,
    Token result,
  }) =>
      BeforeAdd(
        address: address ?? this.address,
        valid: valid ?? this.valid,
      );

  @override
  List<Object> get props => [address, valid];
}

class Loading extends AddCurrencyState {}

class GetToken extends AddCurrencyState {
  final Token result;

  GetToken(this.result);

  @override
  List<Object> get props => [result];
}

class AddSuccess extends AddCurrencyState {}

class AddFail extends AddCurrencyState {}
