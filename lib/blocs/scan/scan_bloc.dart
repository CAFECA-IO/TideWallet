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
      Log.debug(result);
      Currency currency;
      if (result.contains(':')) {
        String prefix = result.split(':')[0];

        if (prefix.toLowerCase() == 'wc')
          yield ScannedWalletConnect(result);
        else if (prefix.toLowerCase() == 'ethereum') {
          try {
            currency = AccountCore().getAllCurrencies().firstWhere(
                (currency) =>
                    currency.type.toLowerCase() == 'currency' &&
                    currency.symbol.toLowerCase() == 'eth' &&
                    currency.publish,
                orElse: () => null);
          } catch (e) {
            currency = null;
          }
        } else if (prefix.toLowerCase() == 'bitcoin') {
          try {
            currency = AccountCore().getAllCurrencies().firstWhere(
                (currency) =>
                    currency.type.toLowerCase() == 'currency' &&
                    currency.symbol.toLowerCase() == 'btc' &&
                    currency.publish,
                orElse: () => null);
          } catch (e) {
            currency = null;
          }
        } else if (prefix.toLowerCase() == 'bitcointestnet') {
          try {
            currency = AccountCore().getAllCurrencies().firstWhere(
                (currency) =>
                    currency.type.toLowerCase() == 'currency' &&
                    currency.symbol.toLowerCase() == 'btc' &&
                    !currency.publish,
                orElse: () => null);
          } catch (e) {
            currency = null;
          }
        } else
          yield ErrorFormat();
        if (currency != null)
          yield ScannedAddress(currency, result);
        else
          yield ErrorFormat();
      } else {
        Currency currency = this._repo.getAddressType(result);
        if (currency != null)
          yield ScannedAddress(currency, result);
        else
          yield ErrorFormat();
      }
    }
  }
}
