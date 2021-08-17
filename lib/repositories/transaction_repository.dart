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
import '../services/account_service.dart';
import '../services/bitcoin_service.dart';
import '../services/transaction_service.dart';
import '../services/transaction_service_based.dart';
import '../services/transaction_service_bitcoin.dart';
import '../services/transaction_service_ethereum.dart';
import '../services/ethereum_service.dart';
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
  late Account _account;
  late AccountService _accountService;
  late TransactionService _transactionService;
  late String? _address;
  late String _tokenTransactionAddress;
  late String _tokenTransactionAmount;
  PublishSubject<AccountMessage> get listener => AccountCore().messenger;

  TransactionRepository();

  void setAccount(Account account) async {
    this._account = account;
    _accountService = AccountCore().getService(this._account.shareAccountId);
    _address =
        (await _accountService.getChangingAddress(_account.shareAccountId))[0];

    switch (this._account.accountType) {
      case ACCOUNT.BTC:
        _transactionService =
            BitcoinTransactionService(TransactionServiceBased());
        break;
      case ACCOUNT.ETH:
      case ACCOUNT.CFC:
        _transactionService =
            EthereumTransactionService(TransactionServiceBased());
        break;
      case ACCOUNT.XRP:
        // TODO: Handle this case.
        break;
    }
  }

  Account get account => this._account;

  bool verifyAmount(Decimal amount, {Decimal? fee}) {
    bool result =
        Decimal.parse(_account.balance) - amount - fee! >= Decimal.zero;
    if (this._account.type == 'token') {
      result = Decimal.parse(_account.balance) - amount >= Decimal.zero &&
          Decimal.parse(_account.shareAccountAmount) - fee >= Decimal.zero;
    }

    Log.debug('verifyAmount: $result');
    return result;
  }

  Future<List<Transaction>> getTransactions() async {
    List<TransactionEntity> transactions = await DBOperator()
        .transactionDao
        .findAllTransactionsById(this._account.id);

    List<TransactionEntity> _transactions1 = transactions
        .where((transaction) => transaction.timestamp == null)
        .toList();
    List<TransactionEntity> _transactions2 = transactions
        .where((transaction) => transaction.timestamp != null)
        .toList()
          ..sort((a, b) => b.timestamp!.compareTo(a.timestamp!));

    List<Transaction> txs = (_transactions1 + _transactions2)
        .map((tx) => Transaction.fromTransactionEntity(tx))
        .toList();
    return txs;
  }

  Future<String> getReceivingAddress() async {
    // TEST: is BackendAddress correct?
    List result = await _accountService.getReceivingAddress(this._account.id);
    String address = result[0];

    return address;
  }

  Future getGasPrice() async {
    Map<TransactionPriority, Decimal> _fee =
        await _accountService.getTransactionFee(this._account.blockchainId);

    return _fee;
  }

  Future<List<dynamic>> getTransactionFee(
      {String? address, Decimal? amount, String? message}) async {
    Map<TransactionPriority, Decimal> _fee =
        await _accountService.getTransactionFee(this._account.blockchainId);

    // TODO if (message = null)
    Decimal? _gasLimit;
    switch (this._account.accountType) {
      case ACCOUNT.BTC:
        BitcoinService _svc = _accountService as BitcoinService;

        List<UnspentTxOut> unspentTxOuts =
            await _svc.getUnspentTxOut(_account.id);
        Map<TransactionPriority, Decimal> fee = {
          TransactionPriority.slow:
              _transactionService.calculateTransactionVSize(
            unspentTxOuts: unspentTxOuts,
            amount: amount!,
            feePerByte: _fee[TransactionPriority.slow]!,
            message: rlp.toBuffer(message ?? Uint8List(0)),
          ),
          TransactionPriority.standard:
              _transactionService.calculateTransactionVSize(
            unspentTxOuts: unspentTxOuts,
            amount: amount,
            feePerByte: _fee[TransactionPriority.standard]!,
            message: rlp.toBuffer(message ?? Uint8List(0)),
          ),
          TransactionPriority.fast:
              _transactionService.calculateTransactionVSize(
            unspentTxOuts: unspentTxOuts,
            amount: amount,
            feePerByte: _fee[TransactionPriority.fast]!,
            message: rlp.toBuffer(message ?? Uint8List(0)),
          ),
        };
        return [fee];
      case ACCOUNT.ETH:
      case ACCOUNT.CFC:
        EthereumService _svc = _accountService as EthereumService;
        if (this._address == null) {
          _address = (await _accountService.getChangingAddress(_account.id))[0];
        }
        String to = address!.contains(':') ? address.split(':')[1] : address;
        String from =
            _address!.contains(':') ? _address!.split(':')[1] : _address!;
        if (this._account.type.toLowerCase() == 'token') {
          // ERC20
          Log.debug('ETH this._account.decimals: ${this._account.decimals}');
          List<int> erc20Func = Cryptor.keccak256round(
              utf8.encode('transfer(address,uint256)'),
              round: 1);
          message = '0x' +
              hex.encode(erc20Func.take(4).toList() +
                  hex.decode(to.substring(2).padLeft(64, '0')) +
                  hex.decode(hex
                      .encode(encodeBigInt(BigInt.parse(
                          Converter.toCurrencySmallestUnit(
                                  amount!, _account.decimals)
                              .toString())))
                      .padLeft(64, '0')) +
                  rlp.toBuffer(message ?? Uint8List(0)));
          Log.debug('ETH erc20Func: $erc20Func');

          amount = Decimal.zero;
          to = this._account.contract!;
        }
        try {
          _gasLimit = await _svc.estimateGasLimit(
              this._account.blockchainId,
              from,
              to,
              amount.toString(),
              '0x' +
                  hex.encode(
                      message == null ? Uint8List(0) : rlp.toBuffer(message)));
        } catch (e) {
          _gasLimit = null;
        }

        return [_fee, _gasLimit, message];
      case ACCOUNT.XRP:
        // TODO: Handle this case.
        return [_fee];
      default:
        return [_fee, _gasLimit];
    }
  }

  Future<bool> verifyAddress(String address) async {
    bool verified = false;
    if (this._address == null) {
      _address = (await _accountService.getChangingAddress(_account.id))[0];
    }
    verified = address != _address && address.length > 0;
    if (verified) {
      verified =
          _transactionService.verifyAddress(address, this.account.publish);
    }
    return verified;
  }

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

  Future<Account> _updateAccount(String id, String balance) async {
    AccountEntity? account = await DBOperator().accountDao.findAccount(id);
    Log.warning('PublishTransaction _updateAccount id: $id');

    AccountEntity updateAccount = account!.copyWith(balance: balance);

    await DBOperator().accountDao.insertAccount(updateAccount);

    List<JoinAccount> entities = await DBOperator()
        .accountDao
        .findJoinedAccountsByShareAccountId(account.shareAccountId);
    JoinAccount entity = entities.firstWhere((v) => v.id == id);

    Account newAccount =
        Account.fromJoinAccount(entity, entities[0], this._account.accountType);

    AccountMessage currMsg =
        AccountMessage(evt: ACCOUNT_EVT.OnUpdateAccount, value: [newAccount]);
    listener.add(currMsg);
    return newAccount;
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
