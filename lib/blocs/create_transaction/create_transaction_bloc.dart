import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'create_transaction_event.dart';
part 'create_transaction_state.dart';

class CreateTransactionBloc extends Bloc<CreateTransactionEvent, CreateTransactionState> {
  CreateTransactionBloc() : super(CreateTransactionInitial());

  @override
  Stream<CreateTransactionState> mapEventToState(
    CreateTransactionEvent event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
