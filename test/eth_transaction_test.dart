import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:tidewallet3/helpers/converter.dart';
import 'package:tidewallet3/helpers/logger.dart';
import 'package:tidewallet3/models/transaction.model.dart';
import 'package:tidewallet3/services/transaction_service.dart';
import 'package:tidewallet3/services/transaction_service_based.dart';
import 'package:tidewallet3/services/transaction_service_ethereum.dart';
import 'package:tidewallet3/helpers/rlp.dart' as rlp;
import 'package:convert/convert.dart';

void main() {
  TransactionService txsvc =
      EthereumTransactionService(TransactionServiceBased());
  String to = "0x88e3bBD42b8ea3623dD10A324A3587eC29480dad";
  String amount = "1";
  String gasPrice = "0.000000000000000001";
  String message = "";
  int nonce = 7;
  int decimals = 18;
  int gasLimit = 21000;
  String fee = '0.000000000000021';
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
}
