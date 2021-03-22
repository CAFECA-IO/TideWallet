import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import '../cores/swap.dart';
import '../models/account.model.dart';
import '../models/transaction.model.dart';
import '../cores/account.dart';
import '../cores/contract.dart';
import '../services/account_service.dart';
import '../services/transaction_service.dart';
import '../services/transaction_service_based.dart';
import '../services/transaction_service_ethereum.dart';
import '../services/ethereum_service.dart';
import '../helpers/rlp.dart' as rlp;
import '../helpers/converter.dart';
import '../helpers/logger.dart'; // --

class SwapRepository {
  SwapRepository();
  Future<Map<String, dynamic>> getSwapDetail(
      Currency sellCurrency, Currency buyCurrency,
      {String sellAmount, String buyAmount}) async {
    return await SwapCore().getSwapDetail(sellCurrency, buyCurrency,
        sellAmount: sellAmount, buyAmount: buyAmount);
  }

  Future<List> swap(
      Uint8List privKey,
      Currency sellCurrency,
      String sellAmount,
      Currency buyCurrency,
      String buyAmount,
      String to,
      Decimal gasPrice,
      Decimal gasLimit) async {
    // ++ Get sellCurrency's cfc currency to do the transaction
    EthereumService _accountService =
        AccountCore().getService(sellCurrency.accountId);
    String address =
        (await _accountService.getReceivingAddress(sellCurrency.id))[0];
    int nonce =
        await _accountService.getNonce(sellCurrency.blockchainId, address);
    Decimal _sellAmount = Decimal.tryParse(sellAmount);
    Decimal _buyAmount = Decimal.tryParse(buyAmount);
    String swapData = await ContractCore()
        .swapData(sellCurrency, _sellAmount, buyCurrency, _buyAmount);
    Decimal fee = gasPrice * gasLimit;
    TransactionService _transactionService =
        EthereumTransactionService(TransactionServiceBased());
    Transaction transaction = _transactionService.prepareTransaction(
        sellCurrency.publish,
        to,
        Converter.toEthSmallestUnit(_sellAmount),
        rlp.toBuffer(swapData),
        nonce: nonce,
        gasPrice: Converter.toEthSmallestUnit(gasPrice),
        gasLimit: gasLimit,
        fee: Converter.toEthSmallestUnit(fee),
        chainId: sellCurrency.chainId,
        privKey: privKey,
        changeAddress: address);
    Decimal balance = Decimal.parse(sellCurrency.amount) - _sellAmount - fee;
    return [transaction, balance];
  }
}
