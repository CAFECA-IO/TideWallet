import 'dart:typed_data';
import 'package:decimal/decimal.dart';

import 'transaction_service.dart';
import '../cores/signer.dart';
import '../models/utxo.model.dart';
import '../models/ethereum_transaction.model.dart';
import '../helpers/ethereum_based_utils.dart';
import '../helpers/cryptor.dart';
import '../helpers/logger.dart';

class EthereumBasedTransactionServiceDecorator extends TransactionService {
  final TransactionService service;
  int chainId;

  EthereumBasedTransactionServiceDecorator(this.service);

  EthereumTransaction _signTransaction(
      EthereumTransaction transaction, Uint8List privKey) {
    Log.debug('ETH from privKey: $privKey');
    Log.debug('_signTransaction nonce: ${transaction.nonce}');
    Log.debug('_signTransaction gasPrice: ${transaction.gasPrice}');
    Log.debug(
        '_signTransaction BigInt.parse(gasPrice): ${BigInt.parse(transaction.gasPrice.toString())}');
    Log.debug('_signTransaction gasUsed: ${transaction.gasUsed}');
    Log.debug('_signTransaction gasUsedToInt: ${transaction.gasUsed.toInt()}');
    Log.debug('_signTransaction amount: ${transaction.amount}');
    Log.debug(
        '_signTransaction BigInt.parse(amount): ${BigInt.parse(transaction.amount.toString())}');
    Log.debug('_signTransaction message: ${transaction.message}');
    Log.debug('_signTransaction to: ${transaction.to}');
    Log.debug(
        '_signTransaction getEthereumAddressBytes(transaction.to): ${getEthereumAddressBytes(transaction.to)}');
    Log.debug('_signTransaction signature.v: ${transaction.signature.v}');
    Log.debug('_signTransaction signature.r: ${transaction.signature.r}');
    Log.debug('_signTransaction signature.s: ${transaction.signature.s}');

    Uint8List payload = encodeToRlp(transaction);
    Uint8List rawDataHash =
        Uint8List.fromList(Cryptor.keccak256round(payload, round: 1));
    MsgSignature signature = Signer().sign(rawDataHash, privKey);
    Log.debug('ETH signature: $signature');

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
    String accountcurrencyId,
    Decimal fee,
    List<UnspentTxOut> unspentTxOuts = const [],
    String changeAddress,
    int keyIndex,
  }) {
    EthereumTransaction transaction = EthereumTransaction.prepareTransaction(
      from: changeAddress,
      to: to.contains(':') ? to.split(':')[1] : to,
      nonce: nonce,
      amount: amount, // in wei
      gasPrice: gasPrice, // in wei
      gasUsed: gasLimit,
      message: message,
      chainId: chainId,
      signature: MsgSignature(BigInt.zero, BigInt.zero, chainId),
      fee: gasLimit * gasPrice, // in wei
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

  @override
  Uint8List extractAddressData(String address, bool publish) {
    return getEthereumAddressBytes(address);
  }
}
