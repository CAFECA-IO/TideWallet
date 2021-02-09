import 'dart:typed_data';

import 'package:rxdart/subjects.dart';
import 'package:decimal/decimal.dart';

import '../services/account_service.dart';
import '../cores/account.dart';
import '../models/account.model.dart';
import '../models/transaction.model.dart';
import '../models/ethereum_transaction.model.dart';
import '../models/bitcoin_transaction.model.dart';
import '../models/utxo.model.dart';
import '../services/transaction_service.dart';
import '../services/transaction_service_based.dart';
import '../services/transaction_service_bitcoin.dart';
import '../services/transaction_service_ethereum.dart';
import '../constants/account_config.dart';

class TransactionRepository {
  static const int AVERAGE_FETCH_FEE_TIME = 1 * 60 * 60 * 1000; // milliseconds
  Currency _currency;
  AccountService _accountService;
  TransactionService _transactionService;
  PublishSubject<AccountMessage> get listener => AccountCore().messenger;
  Transaction _transaction;
  Map<TransactionPriority, Decimal> _fee;
  int _timestamp; // fetch transactionFee timestamp;

  TransactionRepository();

  void setCurrency(Currency currency) {
    this._currency = currency;
    _accountService = AccountCore().getService(this._currency.accountType);

    switch (this._currency.accountType) {
      case ACCOUNT.BTC:
        _transactionService =
            BitcoinTransactionService(TransactionServiceBased());
        break;
      case ACCOUNT.ETH:
        _transactionService =
            EthereumTransactionService(TransactionServiceBased());
        break;
      case ACCOUNT.XRP:
        // TODO: Handle this case.
        break;
    }
  }

  get currency => this._currency;

  // bool validAddress(String address) {
  //   return address.length < 8 ? false : true;
  // }

  bool verifyAmount(Decimal amount, {Decimal fee}) {
    return Decimal.parse(_currency.amount) - amount - fee > Decimal.zero;
  }

  // Future<Map<TransactionPriority, String>> fetchGasPrice() async {
  //   await Future.delayed(Duration(seconds: 1));
  //   return {
  //     TransactionPriority.slow: "33.46200020",
  //     TransactionPriority.standard: "43.20000233",
  //     TransactionPriority.fast: "56.82152409"
  //   };
  // }

  // Future<String> fetchGasLimit() async {
  //   await Future.delayed(Duration(seconds: 1));
  //   return '25148';
  // }

  Future<List<Transaction>> getTransactions() async {
    return await _accountService.getTransactions();
  }

  Future<String> getReceivingAddress(String currency) async {
    return await _accountService.getReceivingAddress(currency);
  }

  Future<List<dynamic>> getTransactionFee(
      {String address, Decimal amount, Uint8List message}) async {
    if (_fee == null ||
        DateTime.now().millisecondsSinceEpoch - _timestamp >
            AVERAGE_FETCH_FEE_TIME) {
      _fee = await _accountService.getTransactionFee();
      _timestamp = DateTime.now().millisecondsSinceEpoch;
    }
    // TODO if (message != null)
    Decimal _gasLimit;
    switch (this._currency.accountType) {
      case ACCOUNT.BTC:
        List<UnspentTxOut> unspentTxOuts =
            await _accountService.getUnspentTxOut(_currency.id);
        Map<TransactionPriority, Decimal> fee = {
          TransactionPriority.slow:
              _transactionService.calculateTransactionVSize(
            unspentTxOuts: unspentTxOuts,
            amount: amount,
            feePerByte: _fee[TransactionPriority.slow],
            message: message,
          ),
          TransactionPriority.standard:
              _transactionService.calculateTransactionVSize(
            unspentTxOuts: unspentTxOuts,
            amount: amount,
            feePerByte: _fee[TransactionPriority.standard],
            message: message,
          ),
          TransactionPriority.fast:
              _transactionService.calculateTransactionVSize(
            unspentTxOuts: unspentTxOuts,
            amount: amount,
            feePerByte: _fee[TransactionPriority.fast],
            message: message,
          ),
        };
        return [fee];
        break;
      case ACCOUNT.ETH:
        EthereumTransaction transaction =
            EthereumTransaction.prepareTransaction();
        _gasLimit = await _accountService
            .estimateGasLimit(transaction.serializeTransaction);
        return [_fee, _gasLimit];
        break;
      case ACCOUNT.XRP:
        // TODO: Handle this case.
        return [_fee];
        break;
      default:
        return [_fee, _gasLimit];
    }
  }

  Future<bool> verifyAddress(String address, bool publish) async {
    bool verified = false;
    String _address = await _accountService.getChangingAddress(_currency.id);
    verified = address != _address;
    if (verified) {
      verified = _transactionService.verifyAddress(address, publish);
    }
    return verified;
  }

  Future<Transaction> prepareTransaction(String to, Decimal amount,
      {Decimal fee,
      Decimal gasPrice,
      Decimal gasLimit,
      Uint8List message}) async {
    switch (this._currency.accountType) {
      case ACCOUNT.BTC:
        String changeAddress;
        List<UnspentTxOut> unspentTxOuts =
            await _accountService.getUnspentTxOut(_currency.id);
        Decimal utxoAmount = Decimal.zero;
        for (UnspentTxOut utxo in unspentTxOuts) {
          if (utxo.locked != 0 ||
              !(utxo.amount > Decimal.zero) ||
              utxo.type == '') continue;
          utxoAmount += utxo.amount;
          if (utxoAmount > (amount + fee)) {
            changeAddress =
                await _accountService.getChangingAddress(_currency.id);
            break;
          } else if (utxoAmount == (amount + fee)) break;
        }
        Transaction transaction = _transactionService.prepareTransaction(
            false, to, amount, message,
            fee: fee,
            unspentTxOuts: unspentTxOuts,
            changeAddress:
                changeAddress); // TODO add account publish property // _repo.currency.publish
        return transaction;
        break;
      case ACCOUNT.ETH:
        // TODO getNonce()
        String from = await _accountService.getReceivingAddress(_currency.id);
        int nonce = await _accountService.getNonce();
        int chainId;
        // TODO use blockchainId to get chainId
        if (this.currency.blockchainId == 'ropsten')
          chainId = 3;
        else if (this.currency.blockchainId == 'rinkeby')
          chainId = 4;
        else if (this.currency.blockchainId == 'mordor')
          chainId = 63;
        else if (this.currency.blockchainId == 'mainnet') // TODO 80000001
          chainId = 1;
        else
          chainId = 0;
        Transaction transaction = _transactionService.prepareTransaction(
          false,
          to,
          amount,
          message,
          changeAddress: from,
          nonce: nonce,
          gasPrice: gasPrice,
          gasLimit: gasLimit,
          chainId: chainId,
        );
        return transaction;
        break;
      case ACCOUNT.XRP:
        return null;
        // TODO: Handle this case.
        break;
      default:
        return null;
    }
  }

  Future<void> publishTransaction(
      String blockchainId, Transaction transaction) async {
    // TODO get blockchainId
    return await _accountService.publishTransaction(
        blockchainId ?? '80000001', _currency.id, transaction);
  }
}
