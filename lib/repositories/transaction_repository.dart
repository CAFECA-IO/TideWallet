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
    List<TransactionEntity> transactions = await DBOperator()
        .transactionDao
        .findAllTransactionsById(this._currency.id);
    Log.debug('this._currency.id: ${this._currency.id}');

    // TODO TEST
    // await DBOperator().transactionDao.deleteTransactions(transactions);

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
    // TODO TEST
    return Uint8List.fromList(hex.decode(
        '9618a6e9bd6e47fe3f3e4e977ed010e67e2ff6cfc7f19d68b73113a914ee6e85'));
    // TEST (END)
    // UserEntity user = await DBOperator().userDao.findUser();
    // web3dart.Wallet wallet = PaperWallet.jsonToWallet([user.keystore, pwd]);
    // List<int> seed = PaperWallet.magicSeed(wallet.privateKey.privateKey);
    // return Uint8List.fromList(seed);
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
    Log.warning("getPrivKey seed: ${hex.encode(seed)}");
    Log.warning("getPrivKey result: ${hex.encode(result)}");
    return result;
  }

  Future<List> prepareTransaction(String pwd, String to, Decimal amount,
      {Decimal fee, Decimal gasPrice, Decimal gasLimit, String message}) async {
    switch (this._currency.accountType) {
      case ACCOUNT.BTC:
        String changeAddress;
        int changeIndex;
        List<UnspentTxOut> unspentTxOuts =
            await _accountService.getUnspentTxOut(_currency.id);
        Decimal utxoAmount = Decimal.zero;
        for (UnspentTxOut utxo in unspentTxOuts) {
          Log.debug(
              'prepareTransaction UnspentTxOut utxo.locked: ${utxo.locked}');
          Log.debug(
              'prepareTransaction UnspentTxOut utxo.amount: ${utxo.amount}');
          Log.debug('prepareTransaction UnspentTxOut utxo.type: ${utxo.type}');

          if (utxo.locked || !(utxo.amount > Decimal.zero) || utxo.type == null)
            continue;
          utxoAmount += utxo.amount; // in smallest uint
          Log.debug('prepareTransaction UnspentTxOut utxoAmount: $utxoAmount');

          utxo.privatekey =
              await getPrivKey(pwd, utxo.chainIndex, utxo.keyIndex);
          Log.debug(
              'prepareTransaction UnspentTxOut utxo.privatekey: ${utxo.privatekey}');

          utxo.publickey = await getPubKey(pwd, utxo.chainIndex, utxo.keyIndex);
          Log.debug(
              'prepareTransaction UnspentTxOut utxo.publickey: ${utxo.publickey}');

          if (utxoAmount > (amount + fee)) {
            Log.debug(
                'prepareTransaction UnspentTxOut utxoAmount: $utxoAmount');
            Log.debug(
                'prepareTransaction UnspentTxOut utxoAmount: ${amount + fee}');

            List result =
                await _accountService.getChangingAddress(_currency.id);
            Log.debug(
                'prepareTransaction UnspentTxOut getChangingAddress: $result');
            changeAddress = result[0];
            changeIndex = result[1];
            break;
          } else if (utxoAmount == (amount + fee)) break;
        }
        Transaction transaction = _transactionService.prepareTransaction(
            this._currency.publish,
            to,
            Converter.toCurrencySmallestUnit(amount, this._currency.decimals),
            message == null ? Uint8List(0) : rlp.toBuffer(message),
            accountcurrencyId: this._currency.id,
            fee: Converter.toCurrencySmallestUnit(fee, this._currency.decimals),
            unspentTxOuts: unspentTxOuts,
            changeIndex: changeIndex,
            changeAddress: changeAddress);
        Decimal balance = Decimal.parse(this._currency.amount) - amount - fee;
        return [
          transaction,
          balance.toString()
        ]; // [Transaction, String(balance)]
        break;
      case ACCOUNT.ETH:
        int nonce = await _accountService.getNonce(
            this._currency.blockchainId, this._address);

        if (currency.symbol.toLowerCase() != 'eth') {
          // ERC20
          List<int> erc20Func = Cryptor.keccak256round(
              utf8.encode('transfer(address,uint256)'),
              round: 1);
          message = '0x' +
              hex.encode(erc20Func.take(4).toList() +
                  hex.decode(to.substring(2).padLeft(64, '0')) +
                  hex.decode(hex
                      .encode(encodeBigInt(BigInt.parse(
                          Converter.toCurrencySmallestUnit(
                                  amount, _currency.decimals ?? 18)
                              .toString()))) // TODO TEST
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
            Converter.toCurrencySmallestUnit(amount, this._currency.decimals),
            message == null ? Uint8List(0) : rlp.toBuffer(message),
            nonce: nonce,
            gasPrice: Converter.toCurrencySmallestUnit(
                gasPrice, this._currency.decimals),
            gasLimit: gasLimit,
            chainId: _currency.chainId,
            privKey: await getPrivKey(pwd, 0, 0),
            changeAddress: this._address);

        Log.debug(
            'transaction: ${hex.encode(transaction.serializeTransaction)}');

        Decimal balance =
            Decimal.parse(this._currency.amount) - amount - gasPrice * gasLimit;
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

    // TODO updateCurrencyAmount ??
    AccountCurrencyEntity account = await DBOperator()
        .accountCurrencyDao
        .findOneByAccountyId(this._currency.id);
    AccountCurrencyEntity updateAccount = AccountCurrencyEntity(
        accountcurrencyId: account.accountcurrencyId,
        accountId: account.accountId,
        numberOfUsedExternalKey: account.numberOfUsedExternalKey,
        numberOfUsedInternalKey: account.numberOfUsedInternalKey,
        currencyId: account.currencyId,
        lastSyncTime: account.lastSyncTime,
        balance: balance);
    await DBOperator().accountCurrencyDao.insertAccount(updateAccount);
    Log.debug('PublishTransaction updateAccount: $updateAccount');
    Currency _curr = this._currency;
    _curr.amount = balance;
    AccountMessage currMsg =
        AccountMessage(evt: ACCOUNT_EVT.OnUpdateCurrency, value: [_curr]);
    listener.add(currMsg);

    // insertTransaction

    TransactionEntity tx = TransactionEntity(
      transactionId: _transaction.id,
      accountcurrencyId: this._currency.id,
      txId: _transaction.txId,
      amount:
          Converter.toCurrencyUnit(_transaction.amount, this._currency.decimals)
              .toString(), //TODO BTC?
      fee: Converter.toCurrencyUnit(_transaction.fee, this._currency.decimals)
          .toString(),
      gasPrice: Converter.toCurrencyUnit(
              _transaction.gasPrice, this._currency.decimals)
          .toString(),
      gasUsed: _transaction.gasUsed.toInt(),
      direction: _transaction.direction.title,
      sourceAddress: _transaction.sourceAddresses,
      destinctionAddress: _transaction.destinationAddresses,
      confirmation: _transaction.confirmations,
      timestamp: _transaction.timestamp,
      note: hex.encode(_transaction.message),
      status: _transaction.status.title,
    );
    Log.debug('PublishTransaction tx: $tx');
    await DBOperator().transactionDao.insertTransaction(tx);

    // inform screen
    List transactions = await DBOperator()
        .transactionDao
        .findAllTransactionsById(this._currency.id);
    transactions.sort((a, b) => a.timestamp.compareTo(b.timestamp));

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
