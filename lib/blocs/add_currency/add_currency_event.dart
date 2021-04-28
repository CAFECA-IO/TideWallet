part of 'add_currency_bloc.dart';

abstract class AddCurrencyEvent extends Equatable {
  const AddCurrencyEvent();

  @override
  List<Object> get props => [];
}


class EnterAddress extends AddCurrencyEvent {
  final String address;

  EnterAddress(this.address);
}

class GetTokenInfo extends AddCurrencyEvent {
  final String address;

  GetTokenInfo(this.address);
}

class AddToken extends AddCurrencyEvent {}