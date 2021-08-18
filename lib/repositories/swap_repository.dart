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
      Account sellAccount, Account buyAccount,
      {String? sellAmount, String? buyAmount}) async {
    return await SwapCore().getSwapDetail(sellAccount, buyAccount,
        sellAmount: sellAmount, buyAmount: buyAmount);
  }

  Future<List> swap(
      Uint8List privKey,
      Account sellAccount,
      String sellAmount,
      Account buyAccount,
      String buyAmount,
      String to,
      Decimal gasPrice,
      Decimal gasLimit) async {
    // ++ Get sellAccount's cfc Account to do the transaction
    EthereumService _accountService =
        AccountCore().getService(sellAccount.shareAccountId) as EthereumService;
    String address =
        (await AccountCore().getReceivingAddress(sellAccount.id))[0];
    int nonce =
        await _accountService.getNonce(sellAccount.blockchainId, address);
    Decimal _sellAmount = Decimal.tryParse(sellAmount)!;
    Decimal _buyAmount = Decimal.tryParse(buyAmount)!;
    String swapData = await ContractCore()
        .swapData(sellAccount, _sellAmount, buyAccount, _buyAmount);
    Decimal fee = gasPrice * gasLimit;
    TransactionService _transactionService =
        EthereumTransactionService(TransactionServiceBased());
    Transaction transaction = _transactionService.prepareTransaction(
        sellAccount.publish,
        to,
        Converter.toEthSmallestUnit(_sellAmount),
        rlp.toBuffer(swapData),
        nonce: nonce,
        gasPrice: Converter.toEthSmallestUnit(gasPrice),
        gasLimit: gasLimit,
        fee: Converter.toEthSmallestUnit(fee),
        chainId: sellAccount.chainId,
        changeAddress: address);
    Decimal balance = Decimal.parse(sellAccount.balance) - _sellAmount - fee;
    return [transaction, balance];
  }
}
