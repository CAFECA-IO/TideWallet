import 'dart:typed_data';
import 'package:decimal/decimal.dart';

import 'transaction_service.dart';
import '../cores/signer.dart';
import '../models/utxo.model.dart';
import '../models/ethereum_transaction.model.dart';
import '../helpers/ethereum_based_utils.dart';
import '../helpers/cryptor.dart';
import '../helpers/converter.dart';

import '../helpers/logger.dart';

class EthereumBasedTransactionServiceDecorator extends TransactionService {
  final TransactionService service;
  int chainId;

  EthereumBasedTransactionServiceDecorator(this.service);

  EthereumTransaction _signTransaction(
      EthereumTransaction transaction, Uint8List privKey) {
    Uint8List payload = encodeToRlp(transaction);

    Uint8List rawDataHash =
        Uint8List.fromList(Cryptor.keccak256round(payload, round: 1));
    Log.debug('privKey: $privKey');
    MsgSignature signature = Signer().sign(rawDataHash, privKey);
    Log.debug('signature: $signature');

    final chainIdV = transaction.chainId != null
        ? (signature.v - 27 + (transaction.chainId * 2 + 35))
        : signature.v;
    signature = MsgSignature(signature.r, signature.s, chainIdV);
    transaction.signature = signature;
    return transaction;
  }

  @override
  EthereumTransaction prepareTransaction(
    bool publish,
    String to,
    Decimal amount,
    Uint8List message, {
    Uint8List privKey, //ETH
    Decimal gasPrice, //ETH
    Decimal gasLimit, //ETH
    int nonce, //ETH
    int chainId, //ETH
    String currencyId,
    Decimal fee,
    List<UnspentTxOut> unspentTxOuts = const [],
    String changeAddress,
    int changeIndex,
  }) {
    EthereumTransaction transaction = EthereumTransaction.prepareTransaction(
      // from: changeAddress, // --
      to: to,
      nonce: nonce,
      amount: Converter.toEthSmallestUnit(amount),
      gasPrice: Converter.toEthSmallestUnit(gasPrice),
      gasUsed: gasLimit,
      message: message,
      chainId: chainId,
      signature: MsgSignature(BigInt.zero, BigInt.zero, chainId),
    );
    return _signTransaction(transaction, privKey);
  }

  @override
  bool verifyAddress(String address, bool publish) {
    bool result = verifyEthereumAddress(address);
    return result;
  }

  @override
  Decimal calculateTransactionVSize(
      {List<UnspentTxOut> unspentTxOuts,
      Decimal feePerByte,
      Decimal amount,
      Uint8List message}) {
    // TODO: implement calculateTransactionVSize
    throw UnimplementedError();
  }
}
