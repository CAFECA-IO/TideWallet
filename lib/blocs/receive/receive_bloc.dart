import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../repositories/transaction_repository.dart';
import '../../models/account.model.dart';

part 'receive_event.dart';
part 'receive_state.dart';

class ReceiveBloc extends Bloc<ReceiveEvent, ReceiveState> {
  TransactionRepository _repo;
  ReceiveBloc(this._repo)
      : assert(_repo != null),
        super(ReceiveInitial(null, null));

  @override
  Stream<ReceiveState> mapEventToState(
    ReceiveEvent event,
  ) async* {
    if (event is GetReceivingAddress) {
      yield AddressLoading(event.currency, '');
      String address = await _repo.getReceivingAddress();
      yield AddressLoaded(event.currency, address);
    }
  }
}
