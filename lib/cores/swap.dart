import 'dart:math'; // --
import 'package:decimal/decimal.dart';

import '../models/account.model.dart';
import '../helpers/logger.dart'; // --

class SwapCore {
  static final SwapCore _instance = SwapCore._internal();
  factory SwapCore() => _instance;

  SwapCore._internal();

  Future<Map<String, dynamic>> getSwapDetail(
      Account sellAccount, Account buyAccount,
      {String? sellAmount, String? buyAmount}) async {
    if (sellAmount != null) {
      Map<String, String> payload = {
        'sellAccountId': sellAccount.id,
        'sellAmount': sellAmount.toString(),
        'buyAccountId': buyAccount.id,
      };
      Map<String, String> result;
      // ++
      // APIResponse res =
      //     await HTTPAgent().post(Endpoint.url + '/swap-detail', payload);
      // if (res.success) {
      //   result = res.data;
      // } else {
      // ++
      // --
      Log.debug('sellAmount.toString(): ${sellAmount.toString()}');
      Decimal randomNumber =
          Decimal.tryParse((Random().nextDouble() * 100).toString())!;
      result = {
        'exchangeRate': '$randomNumber',
        'expectedExchangeAmount':
            '${randomNumber * Decimal.tryParse(sellAmount)!}',
        'contract': '', // ++ buyAccount cfc token contract，
        'gasPrice': '',
        'gasLimit': ''
      };
      // --
      // }
      return result;
    } else if (buyAmount != null) {
      Map<String, String> payload = {
        'sellAccountId': sellAccount.id,
        'sellAmount': sellAmount.toString(),
        'buyAccountId': buyAccount.id,
      };
      Map<String, String> result;
      // ++
      // APIResponse res =
      //     await HTTPAgent().post(Endpoint.url + '/swap-detail', payload);
      // if (res.success) {
      //   result = res.data;
      // } else {
      // ++
      // --
      Decimal randomNumber =
          Decimal.tryParse((Random().nextDouble() * 100).toString())!;
      result = {
        'exchangeRate': '$randomNumber',
        'expectedExchangeAmount':
            '${randomNumber * Decimal.tryParse(sellAmount!)!}',
        'contract': '', // ++ buyAccount cfc token contract
        'gasPrice': '',
        'gasLimit': ''
      };
      // --
      // }
      return result;
    } else {
      throw Error(); // -- debugInfo, null-safety
    }
  }
}
