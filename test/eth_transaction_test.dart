import 'dart:convert';
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tidewallet3/helpers/converter.dart';
import 'package:tidewallet3/helpers/cryptor.dart';
import 'package:tidewallet3/helpers/logger.dart';
import 'package:tidewallet3/helpers/utils.dart';
import 'package:tidewallet3/models/transaction.model.dart';
import 'package:tidewallet3/services/transaction_service.dart';
import 'package:tidewallet3/services/transaction_service_based.dart';
import 'package:tidewallet3/services/transaction_service_ethereum.dart';
import 'package:tidewallet3/helpers/rlp.dart' as rlp;
import 'package:convert/convert.dart';

void main() {
  test("ETH Transaction Test", () {
    TransactionService txsvc =
        EthereumTransactionService(TransactionServiceBased());
    String to = "0x88e3bBD42b8ea3623dD10A324A3587eC29480dad";
    String amount = "1";
    String gasPrice = "0.000000001000000007";
    String message = "";
    int nonce = 0;
    int decimals = 18;
    int gasLimit = 21000;
    String fee = '0.000021000000147';
    int chainId = 8017;
    String privkey =
        '8ed4921bfdbdaa7caaf885e51947c36beb71899752b4b5d4eb7a79309476f00d';
    String from = "0xdda4f819455ef553d5f7249aa5c21ac70538a218";

    Transaction transaction = txsvc.prepareTransaction(
        false,
        to,
        Converter.toCurrencySmallestUnit(Decimal.parse(amount), decimals),
        rlp.toBuffer(message),
        nonce: nonce,
        gasPrice:
            Converter.toCurrencySmallestUnit(Decimal.parse(gasPrice), decimals),
        gasLimit: Decimal.fromInt(gasLimit),
        fee: Converter.toCurrencySmallestUnit(Decimal.parse(fee), decimals),
        chainId: chainId,
        privKey: Uint8List.fromList(hex.decode(privkey)),
        changeAddress: from);

    Log.debug(transaction);
    Log.debug(transaction.serializeTransaction);
    Log.debug(hex.encode(transaction.serializeTransaction));
    Log.debug(
        "0xf8691d018252089488e3bbd42b8ea3623dd10a324a3587ec29480dad880de0b6b3a764000080823ec6a0775ef567d1bf7c97d6fd4bece14252918e594dd757967616cafc725725293f72a0315663803e2ee0a706bf8c152bb93a8aec3ad336004f10ed6d15bb592de948e5");
    Log.debug(hex.encode(transaction.serializeTransaction) ==
        "f8691d018252089488e3bbd42b8ea3623dd10a324a3587ec29480dad880de0b6b3a764000080823ec6a0775ef567d1bf7c97d6fd4bece14252918e594dd757967616cafc725725293f72a0315663803e2ee0a706bf8c152bb93a8aec3ad336004f10ed6d15bb592de948e5");
  });

  test("token tx message", () {
    String to = "0x88e3bbd42b8ea3623dd10a324a3587ec29480dad";
    String amount = "0.01";
    String data = "0x";
    int decimals = 2;
    String erc20Func = hex.encode(Cryptor.keccak256round(
            utf8.encode('transfer(address,uint256)'),
            round: 1)
        .take(4)
        .toList());
    expect(erc20Func, "a9059cbb");
    String encodeTo = to.substring(2).padLeft(64, '0');
    String encodeAmount = hex
        .encode(encodeBigInt(BigInt.parse(
            Converter.toCurrencySmallestUnit(Decimal.parse(amount), decimals)
                .toString())))
        .padLeft(64, '0');
    String encodeData = hex.encode(rlp.toBuffer(data ?? Uint8List(0)));
    expect(erc20Func, "a9059cbb");
    expect(encodeTo,
        "00000000000000000000000088e3bbd42b8ea3623dd10a324a3587ec29480dad");
    expect(encodeAmount,
        "0000000000000000000000000000000000000000000000000000000000000001");
    expect(encodeData, "");
  });
}
