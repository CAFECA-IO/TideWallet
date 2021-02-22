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
    // IMPORTANT: seed cannot reach
    String seed =
        '59f45d6afb9bc00380fed2fcfdd5b36819acab89054980ad6e5ff90ba19c5347';
    Uint8List publicKey = await PaperWallet.getPubKey(hex.decode(seed), 0, 0,
        compressed: false, path: _accountService.path);
    // Uint8List privKey = await PaperWallet.getPrivKey(hex.decode(seed), 0, 0);
    // Log.debug('privKey: ${hex.encode(privKey)}');
    String address = '0x' +
        hex
            .encode(Cryptor.keccak256round(
                publicKey.length % 2 != 0 ? publicKey.sublist(1) : publicKey,
                round: 1))
            .substring(24, 64);
    this._address = address;
    Log.debug(address);
// TEST(end)
    return address;
    // return (await _accountService.getReceivingAddress(this._currency.id))[0];
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
    return await PaperWallet.getPubKey(seed, changeIndex, keyIndex,
        path: _accountService.path);
  }

  Future<Uint8List> getPrivKey(
      String pwd, int changeIndex, int keyIndex) async {
    Uint8List seed = await _getSeed(pwd);
    Uint8List result = await PaperWallet.getPrivKey(seed, changeIndex, keyIndex,
        path: _accountService.path);
    Log.warning("getPrivKey result: ${hex.encode(result)}");
    return result;
  }

  Future<Transaction> prepareTransaction(String pwd, String to, Decimal amount,
      {Decimal fee, Decimal gasPrice, Decimal gasLimit, String message}) async {
    switch (this._currency.accountType) {
      case ACCOUNT.BTC:
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
        return transaction;
        break;
      case ACCOUNT.ETH:
        int nonce = await _accountService.getNonce(
            this._currency.blockchainId, this._address);
        if (currency.type.toLowerCase() == '2') {
          // ERC20
          List<int> erc20Func = Cryptor.keccak256round(
              utf8.encode('transfer(address,uint256)'),
              round: 1);
          message = '0x' +
              hex.encode(erc20Func.take(4).toList() +
                  hex.decode(to.substring(2).padLeft(64, '0')) +
                  hex.decode(hex
                      .encode(encodeBigInt(Converter.toTokenSmallestUnit(
                          amount, _currency.decimals)))
                      .padLeft(64, '0')) +
                  rlp.toBuffer(message));
          Log.debug('to: $to');
          to = this._currency.contract;
          Log.debug('to replace by this._currency.contract: $to');
        }

        Log.debug('_currency.chainId: ${_currency.chainId}');
        Log.debug('gasPrice: $gasPrice');

        Transaction transaction = _transactionService.prepareTransaction(
          this._currency.publish,
          to,
          amount,
          message == null ? Uint8List(0) : rlp.toBuffer(message),
          nonce: nonce, // TODO TEST api nonce is not correct
          gasPrice:
              Decimal.parse('0.00000000111503492'), //gasPrice, // TODO TEST
          gasLimit: gasLimit,
          chainId: _currency.chainId ?? 3, // TODO TEST
          privKey: await getPrivKey(pwd, 0, 0),
        );
        Log.debug(
            'transaction: ${hex.encode(transaction.serializeTransaction)}');
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

  Future<void> publishTransaction(Transaction transaction) async {
    return await _accountService.publishTransaction(
        this._currency.blockchainId, transaction);
  }
}
