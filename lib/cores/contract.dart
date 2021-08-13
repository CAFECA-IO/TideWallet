import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:convert/convert.dart';

import '../cores/account.dart';
import '../constants/account_config.dart';
import '../models/account.model.dart';
import '../helpers/converter.dart';
import '../helpers/rlp.dart' as rlp;
import '../services/account_service.dart';
import '../services/transaction_service.dart';
import '../services/transaction_service_based.dart';
import '../services/transaction_service_bitcoin.dart';
import '../services/transaction_service_ethereum.dart';

enum ContractFunction { deposit, withdraw, transfer, swap, donate }

extension ContractFunctionExt on ContractFunction {
  int get name {
    switch (this) {
      case ContractFunction.deposit:
        return 0x48c73f68;
        break;
      case ContractFunction.withdraw:
        return 0x855511cc;
        break;
      case ContractFunction.transfer:
        return 0xb483afd3;
        break;
      case ContractFunction.swap:
        return 0x695543c3;
        break;
      case ContractFunction.donate:
        return 0x86ba0d37;
        break;
    }
  }
}

class ContractCore {
  static final ContractCore _instance = ContractCore._internal();
  factory ContractCore() => _instance;

  ContractCore._internal();

  Future<dynamic> _extractAddressData(Account account) async {
    dynamic _data;
    AccountService _service = AccountCore().getService(account.shareAccountId);
    String _address =
        (await _service.getReceivingAddress(account.shareAccountId))[0];
    switch (account.accountType) {
      case ACCOUNT.BTC:
        TransactionService _transactionService =
            BitcoinTransactionService(TransactionServiceBased());
        _data = _transactionService.extractAddressData(
            _address, account.publish)[1];
        break;
      case ACCOUNT.ETH:
      case ACCOUNT.CFC:
        TransactionService _transactionService =
            EthereumTransactionService(TransactionServiceBased());
        _data =
            _transactionService.extractAddressData(_address, account.publish);
        break;
      case ACCOUNT.XRP:
        // TODO: Handle this case.
        break;
    }
    return _data;
  }

  /*
  swap 1 BTC to 29.35 ETH to 0xEA674fdDe714fd979de3EdF0F56AA9716B898ec8

  function name: 695543c3
  from cointype: 84 80000000
  from amount: 88 0de0b6b3a7640000
  to cointype: 84 8000003c
  to expect amount: 89 019750257f3db70000
  address: a8 ea674fdde714fd979de3edf0f56aa9716b898ec8
  withdraw: 1

  0x695543c38480000000880de0b6b3a7640000848000003c89019750257f3db70000a8ea674fdde714fd979de3edf0f56aa9716b898ec801
  */
  Future<String> swapData(
    Account sellAccount,
    Decimal sellAmount,
    Account buyAccount,
    Decimal buyAmount,
  ) async {
    BigInt _sellAmount =
        BigInt.from(Converter.toEthSmallestUnit(sellAmount).toInt());
    BigInt _buyAmount =
        BigInt.from(Converter.toEthSmallestUnit(buyAmount).toInt());

    String _address = await _extractAddressData(buyAccount);
    Uint8List _buffer = rlp.encode([
      ContractFunction.swap.name,
      '0x${sellAccount.blockchainId}',
      _sellAmount,
      '0x${buyAccount.blockchainId}',
      _buyAmount,
      _address,
    ]);
    String data = "0x${hex.encode(_buffer)}01";
    return data;
  }

  /*
  withdraw 1 BTC to 3LhS2MWhJC5vJwV1CtmHz3EzV4MNA1w65A

  function name: 855511cc
  coinType: 84 80000000
  amount: 88 0de0b6b3a7640000
  address: 99 05d07e81f97923b57ceed458c6fa493511545397537a73e5f5

  0x855511cc800000000de0b6b3a764000005d07e81f97923b57ceed458c6fa493511545397537a73e5f5
  */
  Future<String> withdrawData(Account account, Decimal amount) async {
    BigInt _amount = BigInt.from(Converter.toEthSmallestUnit(amount).toInt());
    var _address;
    _address = await _extractAddressData(account);
    Uint8List _buffer = rlp.encode([
      ContractFunction.transfer,
      '0x${account.blockchainId}',
      _amount,
      _address
    ]);
    String data = "0x${hex.encode(_buffer)}";
    return data;
  }

  /*
  transfer 1 BTC to 3LhS2MWhJC5vJwV1CtmHz3EzV4MNA1w65A

  function name: b483afd3
  coinType: 84 80000000
  amount: 88 0de0b6b3a7640000
  address: 99 05d07e81f97923b57ceed458c6fa493511545397537a73e5f5
  withdraw: 1

  0xb483afd3800000000de0b6b3a764000005d07e81f97923b57ceed458c6fa493511545397537a73e5f501
  */
  String transferData(Account account, Decimal amount, String address) {
    BigInt _amount = BigInt.from(Converter.toEthSmallestUnit(amount).toInt());
    Uint8List _buffer = rlp.encode([
      ContractFunction.transfer,
      '0x${account.blockchainId}',
      _amount,
      address
    ]);
    String data = "0x${hex.encode(_buffer)}01";
    return data;
  }

  /*
  TODO undefined
  */
  Future<String> donateData(Account account, Decimal amount) async {
    BigInt _amount = BigInt.from(Converter.toEthSmallestUnit(amount).toInt());

    var _address;
    _address = await _extractAddressData(account);

    Uint8List _buffer = rlp.encode([
      ContractFunction.donate,
      '0x${account.blockchainId}',
      _amount,
      _address
    ]);
    String data = "0x${hex.encode(_buffer)}";
    return data;
  }
}
