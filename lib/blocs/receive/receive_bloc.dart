import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../repositories/account_repository.dart';
import '../../models/account.model.dart';
import '../../helpers/logger.dart';

part 'receive_event.dart';
part 'receive_state.dart';

class ReceiveBloc extends Bloc<ReceiveEvent, ReceiveState> {
  AccountRepository _accountRepo;
  ReceiveBloc(this._accountRepo)
      : assert(_accountRepo != null),
        super(ReceiveInitial(null, null));

  @override
  Stream<ReceiveState> mapEventToState(
    ReceiveEvent event,
  ) async* {
    if (event is GetReceivingAddress) {
      yield AddressLoading(event.currency, '');
      String address = await _accountRepo.getReceivingAddress(event.currency);
      Log.debug('GetReceivingAddress: $address');
      yield AddressLoaded(event.currency, address);
    }
  }
}
