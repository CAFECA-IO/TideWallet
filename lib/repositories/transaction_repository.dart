import 'dart:convert';
import 'dart:typed_data';

import 'package:rxdart/subjects.dart';
import 'package:decimal/decimal.dart';
import 'package:convert/convert.dart';
import 'package:web3dart/web3dart.dart' as web3dart;

import '../cores/paper_wallet.dart';
import '../cores/account.dart';
import '../models/account.model.dart';
import '../models/transaction.model.dart';
import '../models/utxo.model.dart';
import '../services/account_service.dart';
import '../services/transaction_service.dart';
import '../services/transaction_service_based.dart';
import '../services/transaction_service_bitcoin.dart';
import '../services/transaction_service_ethereum.dart';
import '../constants/account_config.dart';
import '../helpers/cryptor.dart';
import '../helpers/utils.dart';
import '../helpers/converter.dart';
import '../helpers/rlp.dart' as rlp;
import '../database/db_operator.dart';
import '../database/entity/user.dart';
import '../database/entity/account_currency.dart';
import '../database/entity/transaction.dart';

import '../helpers/logger.dart';

class TransactionRepository {
  static const int AVERAGE_FETCH_FEE_TIME = 1 * 60 * 60 * 1000; // milliseconds
  Currency _currency;
  AccountService _accountService;
  TransactionService _transactionService;
  PublishSubject<AccountMessage> get listener => AccountCore().messenger;
  Map<TransactionPriority, Decimal> _fee;
  int _timestamp; // fetch transactionFee timestamp;
  String _address;

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

  Currency get currency => this._currency;

  bool verifyAmount(Decimal amount, {Decimal fee}) {
    bool result =
        Decimal.parse(_currency.amount) - amount - fee >= Decimal.zero;
    Log.debug('verifyAmount: $result');
    // TODO TEST
    result = true;
    return result;
  }

  Future<List<Transaction>> getTransactions() async {
    List<TransactionEntity> transactions =
        await DBOperator().transactionDao.findAllTransactions();
    Log.debug('this._currency.id: ${this._currency.id}');
    for (TransactionEntity tx in transactions) {
      Log.debug('transactions accountId: ${tx.accountId}');
      Log.debug('transactions currencyId: ${tx.currencyId}');
      Log.debug('transactions txid: ${tx.txId}');
      Log.debug('transactions fee: ${tx.fee}');
    }
    await DBOperator().transactionDao.deleteTransactions(transactions);

    List<Transaction> txs = transactions
        .map((tx) => Transaction.fromTransactionEntity(tx))
        .toList();
    return txs;
  }

  Future<String> getReceivingAddress() async {
    // TEST: is BackendAddress correct?
    List result = await _accountService.getReceivingAddress(this._currency.id);
    String address = result[0];

    return address;
  }

  Future<List<dynamic>> getTransactionFee(
      {String address, Decimal amount, Uint8List message}) async {
    Log.warning('getTransactionFee');
    if (_fee == null ||
        DateTime.now().millisecondsSinceEpoch - _timestamp >
            AVERAGE_FETCH_FEE_TIME) {
      _fee =
          await _accountService.getTransactionFee(this._currency.blockchainId);
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
        if (this._address == null) {
          _address =
              (await _accountService.getChangingAddress(_currency.id))[0];
        }
        _gasLimit = await _accountService.estimateGasLimit(
            this._currency.blockchainId,
            _address,
            address,
            amount.toString(),
            '0x' +
                hex.encode(
                    message == null ? Uint8List(0) : rlp.toBuffer(message)));
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
    if (this._address == null) {
      _address = (await _accountService.getChangingAddress(_currency.id))[0];
    }
    verified = address != _address && address.length > 0;
    if (verified) {
      verified = _transactionService.verifyAddress(address, publish);
    }
    return verified;
  }

  Future<Uint8List> _getSeed(String pwd) async {
    UserEntity user = await DBOperator().userDao.findUser();
    web3dart.Wallet wallet = PaperWallet.jsonToWallet([user.keystore, pwd]);
    List<int> seed = PaperWallet.magicSeed(wallet.privateKey.privateKey);
    return Uint8List.fromList(seed);
  }

  Future<Uint8List> getPubKey(String pwd, int changeIndex, int keyIndex) async {
    Uint8List seed = await _getSeed(pwd);
    return await PaperWallet.getPubKey(seed, changeIndex, keyIndex);
  }

  Future<Uint8List> getPrivKey(
      String pwd, int changeIndex, int keyIndex) async {
    Uint8List seed = await _getSeed(pwd);
    Uint8List result =
        await PaperWallet.getPrivKey(seed, changeIndex, keyIndex);
    // result = await PaperWallet.getPrivKey(
    //     Uint8List.fromList(hex.decode(
    //         'd36777597b9c5cc58a64a4fb842a206bd86da50f276b783aae0cf87e5b058821')),
    //     changeIndex,
    //     keyIndex);
    Log.warning("getPrivKey result: ${hex.encode(result)}");
    return result;
  }

  Future<List> prepareTransaction(String pwd, String to, Decimal amount,
      {Decimal fee, Decimal gasPrice, Decimal gasLimit, String message}) async {
    switch (this._currency.accountType) {
      case ACCOUNT.BTC:
        fee = Decimal.parse('0.00016704'); // TODO TEST
        String changeAddress;
        int changeIndex;
        List<UnspentTxOut> unspentTxOuts =
            await _accountService.getUnspentTxOut(_currency.id);
        Decimal utxoAmount = Decimal.zero;
        for (UnspentTxOut utxo in unspentTxOuts) {
          if (!utxo.locked ||
              !(utxo.amount > Decimal.zero) ||
              utxo.type == null) continue;
          utxoAmount += utxo.amount;
          utxo.privatekey =
              await getPrivKey(pwd, utxo.chainIndex, utxo.keyIndex);
          utxo.publickey = await getPubKey(pwd, utxo.chainIndex, utxo.keyIndex);
          if (utxoAmount > (amount + fee)) {
            List result =
                await _accountService.getChangingAddress(_currency.id);
            changeAddress = result[0];
            changeIndex = result[1];
            break;
          } else if (utxoAmount == (amount + fee)) break;
        }
        Transaction transaction = _transactionService.prepareTransaction(
            this._currency.publish,
            to,
            amount,
            message == null ? Uint8List(0) : rlp.toBuffer(message),
            currencyId: this._currency.id,
            fee: fee,
            unspentTxOuts: unspentTxOuts,
            changeIndex: changeIndex,
            changeAddress: changeAddress);
        Decimal balance = Decimal.parse(this._currency.amount) - fee;
        return [
          transaction,
          balance.toString()
        ]; // [Transaction, String(balance)]
        break;
      case ACCOUNT.ETH:
        int nonce = await _accountService.getNonce(
            this._currency.blockchainId, this._address);
        nonce = 12; // TODO TEST api nonce is not correct
        if (currency.symbol.toLowerCase() != 'eth') {
          // ERC20
          List<int> erc20Func = Cryptor.keccak256round(
              utf8.encode('transfer(address,uint256)'),
              round: 1);
          message = '0x' +
              hex.encode(erc20Func.take(4).toList() +
                  hex.decode(to.substring(2).padLeft(64, '0')) +
                  hex.decode(hex
                      .encode(encodeBigInt(Converter.toTokenSmallestUnit(
                          amount, _currency.decimals ?? 18)))
                      .padLeft(64, '0')) +
                  rlp.toBuffer(message ?? Uint8List(0)));

          amount = Decimal.zero;
          to = this._currency.contract;
          gasLimit = Decimal.fromInt(52212); // TODO TEST
        }
        Log.debug('nonce: $nonce');
        Log.debug('gasPrice: $gasPrice');
        Log.debug('gasLimit: $gasLimit');
        Transaction transaction = _transactionService.prepareTransaction(
            this._currency.publish,
            to,
            amount,
            message == null ? Uint8List(0) : rlp.toBuffer(message),
            nonce: nonce,
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            chainId: _currency.chainId,
            privKey: await getPrivKey(pwd, 0, 0),
            changeAddress: this._address);

        Log.debug(
            'transaction: ${hex.encode(transaction.serializeTransaction)}');

        Decimal balance =
            // Decimal.parse(this._currency.amount) - gasPrice * gasLimit;
            Decimal.parse('1') - gasPrice * gasLimit;

        Log.debug('balance: $balance');
        return [transaction, balance.toString()];
        break;
      case ACCOUNT.XRP:
        return null;
        // TODO: Handle this case.
        break;
      default:
        return null;
    }
  }

  Future<bool> publishTransaction(
      Transaction transaction, String balance) async {
    Log.debug('PublishTransaction transaction: ${transaction.fee}');
    Log.debug('PublishTransaction balance: $balance');
    List result = await _accountService.publishTransaction(
        this._currency.blockchainId, transaction);
    Log.debug('PublishTransaction result: $result');
    bool success = result[0];
    Transaction _transaction = result[1];
    Log.debug('PublishTransaction _transaction: $_transaction');

    if (!success) return success;
    Log.debug('PublishTransaction result: ${result[0]}');

    // TODO updateCurrencyAmount
    AccountCurrencyEntity account = await DBOperator()
        .accountCurrencyDao
        .findOneByAccountyId(this._currency.id);
    AccountCurrencyEntity updateAccount = AccountCurrencyEntity(
        accountcurrencyId: account.accountcurrencyId,
        accountId: account.accountId,
        numberOfUsedExternalKey: account.numberOfUsedExternalKey,
        numberOfUsedInternalKey: account.numberOfUsedInternalKey,
        currencyId: this._currency.id,
        lastSyncTime: account.lastSyncTime,
        balance: balance);
    await DBOperator().accountCurrencyDao.insertAccount(updateAccount);
    Log.debug('PublishTransaction updateAccount: $updateAccount');

    // AccountMessage currMsg = AccountMessage(
    //     evt: ACCOUNT_EVT.OnUpdateCurrency, value: this._currency);
    // listener.add(currMsg);

    // TODO insertTransaction
    Log.debug(
        '_transaction.amount.toString(): ${_transaction.amount.toString()}');
    Log.debug('account.accountId: ${account.accountId}');
    Log.debug('this._currency.id: ${this._currency.id}');
    Log.debug('_transaction.txId: ${_transaction.txId}');
    Log.debug('_transaction.sourceAddresses: ${_transaction.sourceAddresses}');
    Log.debug(
        '_transaction.destinationAddresses: ${_transaction.destinationAddresses}');
    Log.debug(
        '_transaction.gasPrice.toString(): ${_transaction.gasPrice.toString()}');
    Log.debug('_transaction.gasUsed.toInt(): ${_transaction.gasUsed.toInt()}');
    Log.debug('hex.encode(_transaction.message): ${_transaction.message}');
    Log.debug('transaction.fee.toString(): ${transaction.fee.toString()}');

    TransactionEntity tx = TransactionEntity(
        transactionId: _transaction.id,
        amount: _transaction.amount.toString(),
        accountId: account.accountId,
        currencyId: this._currency.id,
        txId: _transaction.txId,
        sourceAddress: _transaction.sourceAddresses,
        destinctionAddress: _transaction.destinationAddresses,
        gasPrice: _transaction.gasPrice.toString(),
        gasUsed: _transaction.gasUsed.toInt(),
        note: hex.encode(_transaction.message),
        fee: _transaction.fee.toString());
    Log.debug('PublishTransaction tx: $tx');
    await DBOperator().transactionDao.insertTransaction(tx);

    // inform screen
    List transactions = await DBOperator()
        .transactionDao
        .findAllTransactionsByCurrencyId(this._currency.id);
    AccountMessage txMsg =
        AccountMessage(evt: ACCOUNT_EVT.OnUpdateTransactions, value: {
      "currency": this._currency,
      "transactions": transactions
          .map((tx) => Transaction.fromTransactionEntity(tx))
          .toList()
    });
    Log.debug('transactions: $transactions');

    listener.add(txMsg);
    return result[0];
  }
}
