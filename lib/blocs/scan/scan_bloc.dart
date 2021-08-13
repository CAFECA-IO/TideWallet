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
      Account? account;
      if (result.contains(':')) {
        String prefix = result.split(':')[0];

        if (prefix.toLowerCase() == 'wc')
          yield ScannedWalletConnect(result);
        else if (prefix.toLowerCase() == 'ethereum') {
          try {
            account = AccountCore().getAllAccounts().firstWhere((account) =>
                account.type.toLowerCase() == 'account' &&
                account.symbol.toLowerCase() == 'eth' &&
                account.publish);
          } catch (e) {
            account = null;
          }
          if (account != null)
            yield ScannedAddress(account, result);
          else
            yield ErrorFormat();
        } else if (prefix.toLowerCase() == 'bitcoin') {
          try {
            account = AccountCore().getAllAccounts().firstWhere((account) =>
                account.type.toLowerCase() == 'account' &&
                account.symbol.toLowerCase() == 'btc' &&
                account.publish);
          } catch (e) {
            account = null;
          }
          if (account != null)
            yield ScannedAddress(account, result);
          else
            yield ErrorFormat();
        } else if (prefix.toLowerCase() == 'bitcointestnet') {
          try {
            account = AccountCore().getAllAccounts().firstWhere((account) =>
                account.type.toLowerCase() == 'account' &&
                account.symbol.toLowerCase() == 'btc' &&
                !account.publish);
          } catch (e) {
            account = null;
          }
          if (account != null)
            yield ScannedAddress(account, result);
          else
            yield ErrorFormat();
        } else
          yield ErrorFormat();
      } else {
        Account? account = this._repo.getAddressType(result);
        if (account != null)
          yield ScannedAddress(account, result);
        else
          yield ErrorFormat();
      }
    }
  }
}
