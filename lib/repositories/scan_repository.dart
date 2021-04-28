import 'package:tidewallet3/cores/account.dart';

import '../models/account.model.dart';
import '../services/transaction_service_based.dart';
import '../services/transaction_service_bitcoin.dart';
import '../services/transaction_service_ethereum.dart';

class ScanRepository {
  Currency getAddressType(String data) {
    BitcoinTransactionService _btcTxSvc =
        BitcoinTransactionService(TransactionServiceBased());
    EthereumTransactionService _ethTxSvc =
        EthereumTransactionService(TransactionServiceBased());
    // ++ ltc/bch/etc svc ... Emily 3/31/2021

    bool result = false;
    try {
      result = _ethTxSvc.verifyAddress(data, true);
      if (result)
        return AccountCore().getAllCurrencies()?.firstWhere(
            (currency) =>
                currency.type.toLowerCase() == 'currency' &&
                currency.symbol.toLowerCase() == 'eth',
            orElse: () => null);
    } catch (e) {
      return null;
    }

    try {
      result = _btcTxSvc.verifyAddress(data, true);
      if (result)
        return AccountCore().getAllCurrencies()?.firstWhere(
            (currency) =>
                currency.type.toLowerCase() == 'currency' &&
                currency.symbol.toLowerCase() == 'btc' &&
                !currency.publish,
            orElse: () => null);
    } catch (e) {
      return null;
    }

    try {
      result = _btcTxSvc.verifyAddress(data, false);
      if (result)
        return AccountCore().getAllCurrencies()?.firstWhere(
            (currency) =>
                currency.type.toLowerCase() == 'currency' &&
                currency.symbol.toLowerCase() == 'btc' &&
                currency.publish,
            orElse: () => null);
    } catch (e) {
      return null;
    }
    return null;
  }
}
