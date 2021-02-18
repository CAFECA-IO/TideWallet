import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:tidewallet3/helpers/logger.dart';

import 'account_service_decorator.dart';
import '../constants/account_config.dart';
import '../services/account_service.dart';

class BitcoinService extends AccountServiceDecorator {
  Timer _utxoTimer;
  BitcoinService(AccountService service) : super(service) {
    this.base = ACCOUNT.BTC;
    this.syncInterval = 5 * 60 * 1000;
  }

  @override
  Decimal calculateFastDee() {
    // TODO: implement calculateFastDee
    throw UnimplementedError();
  }

  @override
  Decimal calculateSlowDee() {
    // TODO: implement calculateSlowDee
    throw UnimplementedError();
  }

  @override
  Decimal calculateStandardDee() {
    // TODO: implement calculateStandardDee
    throw UnimplementedError();
  }

  @override
  getTransactions() {
    // TODO: implement getTransactions
    throw UnimplementedError();
  }

  @override
  void init(String id, ACCOUNT base, {int interval}) {
    this.service.init(id, this.base, interval: this.syncInterval);
  }

  @override
  prepareTransaction() {
    // TODO: implement prepareTransaction
    throw UnimplementedError();
  }

  @override
  Future start() async {
    await this.service.start();

    await this._syncUTXO();

    this._utxoTimer = Timer.periodic(Duration(milliseconds: this.syncInterval), (_) {
      this._syncUTXO();
    });
  }

  @override
  void stop() {
    this.service.stop();

    _utxoTimer?.cancel();
  }

  @override
  Decimal toCoinUnit() {
    // TODO: implement toCoinUnit
    throw UnimplementedError();
  }

  @override
  Decimal toSmallUnit() {
    // TODO: implement toSmallUnit
    throw UnimplementedError();
  }

  @override
  publishTransaction() {
    // TODO: implement publishTransaction
    throw UnimplementedError();
  }

  @override
  Future<String> getReceivingAddress() async {
    // TODO: implement publishTransaction
    throw UnimplementedError();
  }

  Future _syncUTXO() async {
    int now = DateTime.now().millisecondsSinceEpoch;

    if (now - this.service.lastSyncTimestamp > this.syncInterval) {
      Log.info('_syncUTXO');
    }
  }
}
