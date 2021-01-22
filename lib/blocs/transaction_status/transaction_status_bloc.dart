import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'transaction_status_event.dart';
part 'transaction_status_state.dart';

class TransactionStatusBloc extends Bloc<TransactionStatusEvent, TransactionStatusState> {
  TransactionStatusBloc() : super(TransactionStatusInitial());

  @override
  Stream<TransactionStatusState> mapEventToState(
    TransactionStatusEvent event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
