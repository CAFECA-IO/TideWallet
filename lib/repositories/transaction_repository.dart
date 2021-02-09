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
import '../helpers/utils.dart';
import '../helpers/ethereum_based_utils.dart';
import '../helpers/rlp.dart' as rlp;
import '../database/db_operator.dart';
import '../database/entity/user.dart' as UserEnity;

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
    return Decimal.parse(_currency.amount) - amount - fee > Decimal.zero;
  }

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
        if (this._address == null) {
          _address = await _accountService.getChangingAddress(_currency.id);
        }
        _gasLimit = await _accountService.estimateGasLimit(_address, address,
            amount.toString(), hex.encode(message ?? Uint8List(0)));
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
      _address = await _accountService.getChangingAddress(_currency.id);
    }
    verified = address != _address;
    if (verified) {
      verified = _transactionService.verifyAddress(address, publish);
    }
    return verified;
  }

  Future<Uint8List> _getSeed(String pwd) async {
    UserEnity.User user = await DBOperator().userDao.findUser();
    web3dart.Wallet wallet = PaperWallet.jsonToWallet([user.keystore, pwd]);
    List<int> seed = PaperWallet.magicSeed(wallet.privateKey.privateKey);
    return Uint8List.fromList(seed);
  }

  Future<Uint8List> getPubKey(String pwd, int changeIndex, int keyIndex) async {
    Uint8List seed = await _getSeed(pwd);
    return PaperWallet.getPubKey(seed, changeIndex, keyIndex);
  }

  Future<Uint8List> getPrivKey(
      String pwd, int changeIndex, int keyIndex) async {
    Uint8List seed = await _getSeed(pwd);
    return PaperWallet.getPrivKey(seed, changeIndex, keyIndex);
  }

  Future<Transaction> prepareTransaction(String pwd, String to, Decimal amount,
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
          utxo.privatekey =
              await getPrivKey(pwd, utxo.chainIndex, utxo.keyIndex);
          utxo.publickey = await getPubKey(pwd, utxo.chainIndex, utxo.keyIndex);
          if (utxoAmount > (amount + fee)) {
            changeAddress =
                await _accountService.getChangingAddress(_currency.id);
            break;
          } else if (utxoAmount == (amount + fee)) break;
        }
        Transaction transaction = _transactionService.prepareTransaction(
            this._currency.publish, to, amount, message,
            fee: fee,
            unspentTxOuts: unspentTxOuts,
            changeAddress: changeAddress);
        return transaction;
        break;
      case ACCOUNT.ETH:
        String from = await _accountService.getReceivingAddress(_currency.id);
        int nonce = await _accountService.getNonce();
        if (currency.symbol.toLowerCase() != 'eth') {
          // ERC20
          List<int> erc20Func =
              keccak256(utf8.encode('transfer(address,uint256)'));
          message = Uint8List.fromList(erc20Func.take(4).toList() +
              hex.decode(to.substring(2).padLeft(64, '0')) +
              hex.decode(hex
                  .encode(encodeBigInt(
                      toTokenSmallestUnit(amount, _currency.decimals)))
                  .padLeft(64, '0')) +
              rlp.toBuffer(message));
        }
        Transaction transaction = _transactionService.prepareTransaction(
          this._currency.publish,
          to,
          amount,
          message,
          changeAddress: from,
          nonce: nonce,
          gasPrice: gasPrice,
          gasLimit: gasLimit,
          chainId: _currency.chainId,
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
    return await _accountService.publishTransaction(
        blockchainId ?? this._currency.blockchainId, _currency.id, transaction);
  }
}
