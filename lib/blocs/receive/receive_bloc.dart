import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../repositories/transaction_repository.dart';
import '../../models/account.model.dart';

part 'receive_event.dart';
part 'receive_state.dart';

class ReceiveBloc extends Bloc<ReceiveEvent, ReceiveState> {
  late TransactionRepository _repo;
  ReceiveBloc(this._repo) : super(ReceiveInitial(null, null));

  @override
  Stream<ReceiveState> mapEventToState(
    ReceiveEvent event,
  ) async* {
    if (event is GetReceivingAddress) {
      yield AddressLoading(event.account, '');
      String address = await _repo.getReceivingAddress();
      yield AddressLoaded(event.account, address);
    }
  }
}
