import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/account.model.dart';
import '../../cores/account.dart';
import '../../repositories/scan_repository.dart';

import '../../helpers/logger.dart'; // -- debug

part 'scan_event.dart';
part 'scan_state.dart';

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  ScanRepository _repo;
  ScanBloc(this._repo) : super(ScanInitial());

  @override
  Stream<ScanState> mapEventToState(
    ScanEvent event,
  ) async* {
    if (event is ScanQRCode) {
      String result = event.result;
      if (result.contains(':')) {
        String prefix = result.split(':')[0];
        String data = result.split(':')[1];
        if (prefix.toLowerCase() == 'wc')
          yield ScannedWalletConnect(data);
        else if (prefix.toLowerCase() == 'ethereum') {
          Currency currency = AccountCore().getAllCurrencies()?.firstWhere(
              (currency) =>
                  currency.type.toLowerCase() == 'currency' &&
                  currency.symbol.toLowerCase() == 'eth');
          yield ScannedAddress(currency, data);
        } else if (prefix.toLowerCase() == 'bitcoin' ||
            prefix.toLowerCase() == 'bitcointestnet') {
          Currency currency = AccountCore().getAllCurrencies()?.firstWhere(
              (currency) =>
                  currency.type.toLowerCase() == 'currency' &&
                  currency.symbol.toLowerCase() == 'btc');
          yield ScannedAddress(currency, data);
        } else
          yield ErrorFormat();
      } else {
        String result = event.result;
        Currency currency = this._repo.getAddressType(result);
        if (currency != null)
          yield ScannedAddress(currency, result);
        else
          yield ErrorFormat();
      }
    }
  }
}
