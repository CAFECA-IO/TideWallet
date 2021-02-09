import 'dart:typed_data';
import 'package:decimal/decimal.dart';

import 'transaction_service.dart';
import '../cores/signer.dart';
import '../models/utxo.model.dart';
import '../models/ethereum_transaction.model.dart';
import '../helpers/ethereum_based_utils.dart';
import '../helpers/utils.dart';

class EthereumBasedTransactionServiceDecorator extends TransactionService {
  final TransactionService service;
  int chainId;

  EthereumBasedTransactionServiceDecorator(this.service);

  EthereumTransaction _signTransaction(EthereumTransaction transaction) {
    // !! TODO get privateKey
    Uint8List payload = encodeToRlp(transaction);
    Uint8List rawDataHash = keccak256(payload);
    // MsgSignature signature = Signer().sign(
    //     rawDataHash,
    //     this.hdWallet.getExtendedPrivateKey(this.account.path,
    //         chainIndex: utxo.chainIndex, keyIndex: utxo.keyIndex));
    final chainIdV = transaction.chainId != null
        ? (transaction.signature.v - 27 + (transaction.chainId * 2 + 35))
        : transaction.signature.v;

    // signature = MsgSignature(signature.r, signature.s, chainIdV);
    // transaction.signature = signature;
    return transaction;
  }

  @override
  EthereumTransaction prepareTransaction(
      bool publish, String to, Decimal amount, Uint8List message,
      {Decimal fee,
      Decimal gasPrice,
      Decimal gasLimit,
      int nonce,
      int chainId,
      List<UnspentTxOut> unspentTxOuts = const [],
      String changeAddress}) {
    EthereumTransaction transaction = EthereumTransaction.prepareTransaction(
      from: changeAddress, // !! TODO
      to: to,
      nonce: nonce,
      amount: amount,
      gasPrice: gasPrice,
      gasUsed: gasLimit,
      message: message ?? Uint8List(0),
      chainId: chainId, // TODO
      signature: MsgSignature(BigInt.zero, BigInt.zero, chainId),
    );
    return _signTransaction(transaction);
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
