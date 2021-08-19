import 'package:decimal/decimal.dart';

import '../cores/account.dart';
import '../cores/contract.dart';
import '../cores/swap.dart';
import '../models/account.model.dart';

class SwapRepository {
  SwapRepository();
  Future<Map<String, dynamic>> getSwapDetail(
      Account sellAccount, Account buyAccount,
      {String? sellAmount, String? buyAmount}) async {
    return await SwapCore().getSwapDetail(sellAccount, buyAccount,
        sellAmount: sellAmount, buyAmount: buyAmount);
  }

  List<Account> get accountList => AccountCore().accountList;

  Future swap(
      String thirdPartyId,
      Account sellAccount,
      String sellAmount,
      Account buyAccount,
      String buyAmount,
      String to,
      Decimal gasPrice,
      Decimal gasLimit) async {
    // ++ Get sellAccount's cfc Account to do the transaction

    Decimal _sellAmount = Decimal.tryParse(sellAmount)!;
    Decimal _buyAmount = Decimal.tryParse(buyAmount)!;
    String swapData = await ContractCore()
        .swapData(sellAccount, _sellAmount, buyAccount, _buyAmount);
    Decimal fee = gasPrice * gasLimit;

    return AccountCore().sendTransaction(sellAccount.id,
        thirdPartyId: thirdPartyId,
        to: to,
        amount: _sellAmount,
        message: swapData,
        fee: fee,
        gasLimit: gasLimit,
        gasPrice: gasPrice);
  }
}
