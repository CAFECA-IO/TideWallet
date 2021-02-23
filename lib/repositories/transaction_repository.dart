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
    return await _accountService.getTransactions();
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
    verified = address != _address;
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
    // Uint8List result = await PaperWallet.getPrivKey(
    //     Uint8List.fromList(hex.decode(
    //         '59f45d6afb9bc00380fed2fcfdd5b36819acab89054980ad6e5ff90ba19c5347')),
    //     changeIndex,
    //     keyIndex);
    Uint8List result =
        await PaperWallet.getPrivKey(seed, changeIndex, keyIndex);
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
          // to = this._currency.contract;
          to = '0xfaCCcF05e2C4fac8DCDD17d3A567CaFea71583E0'; // TODO TEST
          gasLimit = Decimal.fromInt(52212); // TODO TEST
        }
        gasPrice = Decimal.parse('0.00000000111503492'); // TODO TEST
        Transaction transaction = _transactionService.prepareTransaction(
            this._currency.publish,
            to,
            amount,
            message == null ? Uint8List(0) : rlp.toBuffer(message),
            nonce: nonce, // TODO TEST api nonce is not correct
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            chainId: _currency.chainId,
            privKey: await getPrivKey(pwd, 0, 0),
            changeAddress: this._address);
        Log.debug(
            'transaction: ${hex.encode(transaction.serializeTransaction)}');

        Decimal balance =
            Decimal.parse(this._currency.amount) - gasPrice * gasLimit;
        Log.debug('balance: $balance');
        return [transaction, balance];
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
      Transaction transaction, String balance) async {
    await _accountService.publishTransaction(
        this._currency.blockchainId, transaction);

    // TODO updateCurrencyAmount
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
    Log.debug('balance1: $balance');

    AccountMessage currMsg = AccountMessage(
        evt: ACCOUNT_EVT.OnUpdateCurrency,
        value: AccountCore().currencies[this._accountService.base]);
    listener.add(currMsg);
    Log.debug('balance2: $balance');

    // TODO insertTransaction
    TransactionEntity tx = TransactionEntity(
        transactionId: transaction.id,
        amount: transaction.amount.toString(),
        accountId: account.accountId,
        currencyId: currency.currencyId,
        txId: transaction.txId,
        confirmation: 0,
        sourceAddress: transaction.sourceAddresses,
        destinctionAddress: transaction.destinationAddresses,
        gasPrice: transaction.gasPrice.toString(),
        gasUsed: transaction.gasUsed.toInt(),
        fee: transaction.fee.toString(),
        direction: TransactionDirection.sent.title,
        status: transaction.status.title,
        timestamp: transaction.timestamp);
    await DBOperator().transactionDao.insertTransaction(tx);
    Log.debug('balance3: $balance');

    // inform screen
    List transactions = await DBOperator()
        .transactionDao
        .findAllTransactionsByCurrencyId(this._currency.id);
    AccountMessage txMsg =
        AccountMessage(evt: ACCOUNT_EVT.OnUpdateTransactions, value: {
      "currency": currency,
      "transactions": transactions
          .map((tx) => Transaction.fromTransactionEntity(tx))
          .toList()
    });
    Log.debug('balance4: $balance');

    listener.add(txMsg);
    return;
  }
}
