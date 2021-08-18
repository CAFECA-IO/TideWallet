import 'dart:convert';
import 'dart:typed_data';

import 'package:rxdart/subjects.dart';
import 'package:decimal/decimal.dart';
import 'package:convert/convert.dart';

import '../cores/paper_wallet.dart';
import '../cores/account.dart';
import '../models/account.model.dart';
import '../models/transaction.model.dart';
import '../models/utxo.model.dart';

import '../constants/account_config.dart';
import '../helpers/cryptor.dart';
import '../helpers/utils.dart';
import '../helpers/converter.dart';
import '../helpers/rlp.dart' as rlp;
import '../database/db_operator.dart';
import '../database/entity/transaction.dart';
import '../database/entity/account.dart';

import '../helpers/logger.dart';

class TransactionRepository {
  Account? _account;
  String? _address;
  String? _tokenTransactionAddress;
  String? _tokenTransactionAmount;
  PublishSubject<AccountMessage> get listener => AccountCore().messenger;

  TransactionRepository();

  set account(Account account) => this._account = account;
  Account get account => this._account!;

  bool verifyAmount(String amount, String fee) =>
      AccountCore().verifyAmount(this.account.id, amount, fee);

  Future<bool> verifyAddress(String address) =>
      AccountCore().verifyAddress(this.account.id, address);

  Future<Map> getAccountDetail() =>
      AccountCore().getAccountDetail(this.account.id);

  Future<String> getReceivingAddress() =>
      AccountCore().getReceivingAddress(this.account.id);

  Future<Map> getTransactionFee(
          {String? address,
          String? amount,
          String? message,
          TransactionPriority? priority}) =>
      AccountCore().getTransactionFee(this.account.id,
          to: address, amount: amount, message: message, priority: priority);

  Future sendTransaction(Transaction transaction) =>
      AccountCore().sendTransaction(this.account.id, transaction);

  Future<List> prepareTransaction(String to, Decimal amount,
      {Decimal? fee,
      Decimal? gasPrice,
      Decimal? gasLimit,
      String? message}) async {
    switch (this._account.accountType) {
      case ACCOUNT.BTC:
        BitcoinService _svc = _accountService as BitcoinService;
        late String changeAddress;
        late int keyIndex;
        List<UnspentTxOut> unspentTxOuts =
            await _svc.getUnspentTxOut(_account.id);
        Log.debug('unspentTxOuts: $unspentTxOuts');
        Decimal utxoAmount = Decimal.zero;
        Log.btc('amount + fee: ${amount + fee!}');
        List<UnspentTxOut> _utxos = [];
        for (UnspentTxOut utxo in unspentTxOuts) {
          Log.btc('utxo.locked: ${utxo.locked}');
          if (utxo.locked || !(utxo.amount > Decimal.zero) || utxo.type == null)
            continue;
          utxoAmount += utxo.amount; // in currency uint
          Log.btc('utxoAmount: $utxoAmount');
          Log.btc('utxo.amount: ${utxo.amount}');
          utxo.publickey = await PaperWalletCore().getPubKey(
              changeIndex: utxo.changeIndex, keyIndex: utxo.keyIndex);
          _utxos.add(utxo);
          if (utxoAmount > (amount + fee)) {
            List result = await _svc.getChangingAddress(_account.id);
            Log.btc('prepareTransaction getChangingAddress: $result');
            changeAddress = result[0];
            keyIndex = result[1];
            break;
          } else if (utxoAmount == (amount + fee)) break;
        }
        Transaction transaction = _transactionService.prepareTransaction(
          this._account.publish,
          to,
          Converter.toCurrencySmallestUnit(amount, this._account.decimals),
          message == null ? Uint8List(0) : rlp.toBuffer(message),
          accountId: this._account.id,
          fee: Converter.toCurrencySmallestUnit(
              fee, this._account.shareAccountDecimals),
          unspentTxOuts: _utxos,
          keyIndex: keyIndex,
          changeAddress: changeAddress,
        );
        Decimal balance = Decimal.parse(this._account.balance) - amount - fee;
        return [
          transaction,
          balance.toString()
        ]; // [Transaction, String(balance)]

      case ACCOUNT.ETH:
      case ACCOUNT.CFC:
        EthereumService _svc = _accountService as EthereumService;
        int nonce =
            await _svc.getNonce(this._account.blockchainId, this._address!);

        Decimal fee = gasPrice! * gasLimit!;
        Decimal balance = Decimal.parse(this._account.balance) - amount - fee;
        if (this._account.type.toLowerCase() == 'token') {
          // ERC20
          _tokenTransactionAmount = amount.toString();
          _tokenTransactionAddress = to;
          balance =
              Decimal.parse(this._account.balance) - amount; // currency unint
          amount = Decimal.zero;
          to = this._account.contract!;
        }

        Transaction transaction = _transactionService.prepareTransaction(
            this
                ._account
                .publish, // ++ debugInfo, isMainnet required not publish, null-safety
            to,
            Converter.toCurrencySmallestUnit(amount, this._account.decimals),
            rlp.toBuffer(message),
            nonce: nonce,
            gasPrice: Converter.toCurrencySmallestUnit(
                gasPrice, this._account.shareAccountDecimals),
            gasLimit: gasLimit,
            fee: Converter.toCurrencySmallestUnit(
                fee, this._account.shareAccountDecimals),
            chainId: _account.chainId,
            changeAddress: this._address);

        Log.debug(
            'transaction: ${hex.encode(transaction.serializeTransaction)}');

        return [transaction, balance.toString()];

      case ACCOUNT.XRP:
        throw Exception("Currency is not suppoorted");

      default:
        throw Exception("Currency is not suppoorted");
    }
  }

  Future<List> publishTransaction(Transaction transaction, String balance,
      {String? blockchainId}) async {
    List result = await _accountService.publishTransaction(
        blockchainId ?? this._account.blockchainId, transaction);
    bool success = result[0];
    Transaction _transaction = result[1];
    if (!success) return [success];
    _pushResult(_transaction, Decimal.parse(balance));
    return result;
  }

  _pushResult(Transaction transaction, Decimal balance) async {
    // TODO updateCurrencyAmount
    String _amount =
        Converter.toCurrencyUnit(transaction.amount, this._account.decimals)
            .toString();
    String _fee = Converter.toCurrencyUnit(
            transaction.fee, this._account.shareAccountDecimals)
        .toString();
    String _gasPrice;

    Account _acc = this._account;
    _acc = _acc.copyWith(balance: balance.toString());

    switch (this._account.accountType) {
      case ACCOUNT.BTC:
        _updateAccount(this._account.id, balance.toString());
        _updateTransaction(this._account.id, _acc, transaction, _amount, _fee);
        break;
      case ACCOUNT.ETH:
      case ACCOUNT.CFC:
        _gasPrice = Converter.toCurrencyUnit(
                transaction.gasPrice!, this._account.shareAccountDecimals)
            .toString();
        if (this._account.type.toLowerCase() != 'token') {
          _updateAccount(this._account.id, balance.toString());
          _updateTransaction(this._account.id, _acc, transaction, _amount, _fee,
              gasPrice: _gasPrice);
        } else {
          _acc.balance = balance.toString();
          _updateAccount(this._account.id, balance.toString());
          _updateTransaction(this._account.id, _acc, transaction,
              _tokenTransactionAmount, _fee,
              gasPrice: _gasPrice,
              destinationAddresses: _tokenTransactionAddress);
          Account _accParent = await _updateAccount(
              this._account.shareAccountId,
              (Decimal.parse(this._account.shareAccountAmount) -
                      Decimal.parse(_fee))
                  .toString());
          _updateTransaction(
              this._account.shareAccountId, _accParent, transaction, '0', _fee,
              gasPrice: _gasPrice,
              destinationAddresses: _tokenTransactionAddress);
        }
        break;
      case ACCOUNT.XRP:
        // TODO: Handle this case.
        break;
    }
  }

  _updateTransaction(String id, Account account, Transaction transaction,
      String amount, String fee,
      {String? gasPrice, String? destinationAddresses}) async {
    // insertTransaction
    TransactionEntity tx = TransactionEntity.fromTransaction(
        account, transaction, amount, fee, gasPrice!, destinationAddresses);
    await DBOperator().transactionDao.insertTransaction(tx);
    // inform screen
    List<TransactionEntity> transactions =
        await DBOperator().transactionDao.findAllTransactionsById(id);
    List<TransactionEntity> _transactions1 = transactions
        .where((transaction) => transaction.timestamp == null)
        .toList();
    List<TransactionEntity> _transactions2 = transactions
        .where((transaction) => transaction.timestamp != null)
        .toList()
          ..sort((a, b) => b.timestamp!.compareTo(a.timestamp!));

    AccountMessage txMsg =
        AccountMessage(evt: ACCOUNT_EVT.OnUpdateTransactions, value: {
      "account": account,
      "transactions": (_transactions1 + _transactions2)
          .map((tx) => Transaction.fromTransactionEntity(tx))
          .toList()
    });

    listener.add(txMsg);
  }
}
