import 'dart:typed_data';
import 'package:decimal/decimal.dart';

import 'transaction_service.dart';
import '../cores/paper_wallet.dart';
import '../cores/signer.dart';
import '../models/utxo.model.dart';
import '../models/ethereum_transaction.model.dart';
import '../helpers/ethereum_based_utils.dart';
import '../helpers/cryptor.dart';
import '../helpers/logger.dart';
import '../helpers/rlp.dart' as rlp;

class EthereumBasedTransactionServiceDecorator extends TransactionService {
  final TransactionService service;
  late int chainId;

  EthereumBasedTransactionServiceDecorator(this.service);

  Future<EthereumTransaction> _signTransaction(
      String thirdPartyId, EthereumTransaction transaction,
      {int? changeIndex, int? keyIndex}) async {
    Uint8List payload = encodeToRlp(transaction);
    Uint8List rawDataHash = Cryptor.keccak256round(payload, round: 1);
    MsgSignature signature = await PaperWalletCore().sign(
        thirdPartyId: thirdPartyId,
        data: rawDataHash,
        changeIndex: changeIndex ?? 0,
        keyIndex: keyIndex ?? 0);
    Log.debug('ETH signature: $signature');

    final chainIdV = transaction.chainId != null
        ? (signature.v - 27 + (transaction.chainId! * 2 + 35))
        : signature.v;
    signature = MsgSignature(signature.r, signature.s, chainIdV);
    transaction.signature = signature;
    return transaction;
  }

  @override
  Future<EthereumTransaction> prepareTransaction(
    String thirdPartyId,
    bool isMainet,
    String to,
    Decimal amount, {
    String? message,
    Decimal? gasPrice, //ETH
    Decimal? gasLimit, //ETH
    int? nonce, //ETH
    int? chainId, //ETH
    String? accountId,
    Decimal? fee,
    List<UnspentTxOut>? unspentTxOuts = const [],
    String? changeAddress,
    int? keyIndex,
  }) async {
    EthereumTransaction transaction = EthereumTransaction.prepareTransaction(
      from: changeAddress!,
      to: to.contains(':') ? to.split(':')[1] : to,
      nonce: nonce!,
      amount: amount, // in wei
      gasPrice: gasPrice!, // in wei
      gasUsed: gasLimit!,
      message: rlp.toBuffer(message),
      chainId: chainId!,
      signature: MsgSignature(BigInt.zero, BigInt.zero, chainId),
      fee: gasLimit * gasPrice, // in wei
    );
    return await _signTransaction(thirdPartyId, transaction);
  }

  @override
  bool verifyAddress(String address, bool publish) {
    bool result = verifyEthereumAddress(address);
    return result;
  }

  @override
  Uint8List extractAddressData(String address, bool publish) {
    return getEthereumAddressBytes(address);
  }
}
