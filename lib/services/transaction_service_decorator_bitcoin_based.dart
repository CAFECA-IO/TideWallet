import 'dart:typed_data';
import 'package:decimal/decimal.dart';
import 'package:convert/convert.dart';

import 'transaction_service.dart';
import '../cores/signer.dart';
import '../helpers/utils.dart';
import '../helpers/cryptor.dart';
import '../models/utxo.model.dart';
import '../models/transaction.model.dart';
import '../models/bitcoin_transaction.model.dart';
import '../helpers/bitcoin_based_utils.dart';
import '../helpers/logger.dart';
import '../helpers/rlp.dart' as rlp;

class BitcoinBasedTransactionServiceDecorator extends TransactionService {
  static const int _Index_ExternalChain = 0;
  static const int _Index_InternalChain = 1;

  final TransactionService service;
  int p2pkhAddressPrefixTestnet;
  int p2pkhAddressPrefixMainnet;
  int p2shAddressPrefixTestnet;
  int p2shAddressPrefixMainnet;
  String bech32HrpMainnet;
  String bech32HrpTestnet;
  String bech32Separator;
  SegwitType segwitType;
  bool supportSegwit = true;
  BitcoinBasedTransactionServiceDecorator(this.service);
  @override
  bool verifyAddress(String address, bool publish) {
    bool verified = isP2pkhAddress(
            address,
            publish
                ? this.p2pkhAddressPrefixMainnet
                : this.p2pkhAddressPrefixTestnet) ||
        isP2shAddress(
            address,
            publish
                ? this.p2shAddressPrefixMainnet
                : this.p2shAddressPrefixTestnet) ||
        isSegWitAddress(
            address,
            publish ? this.bech32HrpMainnet : this.bech32HrpTestnet,
            bech32Separator); // TODO BitcoinCash Address condition
    return verified;
  }

  Transaction _signTransaction(BitcoinTransaction transaction) {
    Log.btc('_unsignTransaction: ${transaction.serializeTransaction}');
    Log.btc(
        '_unsignTransaction hex: ${hex.encode(transaction.serializeTransaction)}');

    int index = 0;
    while (index < transaction.inputs.length) {
      Uint8List rawData = transaction.getRawDataToSign(index);
      Uint8List rawDataHash = Cryptor.sha256round(rawData);
      UnspentTxOut utxo = transaction.inputs[index].utxo;
      MsgSignature sig = Signer().sign(rawDataHash, utxo.privatekey);
      Uint8List buffer = new Uint8List(64);
      Log.btc('utxo txId: ${utxo.txId}');
      Log.btc('utxo.amount: ${utxo.amount}');

      buffer.setRange(0, 32, encodeBigInt(sig.r));
      buffer.setRange(32, 64, encodeBigInt(sig.s));
      Uint8List signature = Signer()
          .encodeSignature(buffer, transaction.inputs[index].hashType.value);
      transaction.inputs[index].addSignature(signature);
      index++;
    }
    Uint8List signedTransaction = transaction.serializeTransaction;
    Log.btc('_signTransaction: $signedTransaction');
    Log.btc('_signTransaction hex: ${hex.encode(signedTransaction)}');
    return transaction;
  }

  @override
  BitcoinTransaction prepareTransaction(
    bool publish,
    String to,
    Decimal amount,
    Uint8List message, {
    Uint8List privKey,
    Decimal gasPrice,
    Decimal gasLimit,
    int nonce,
    int chainId,
    String accountcurrencyId,
    Decimal fee,
    List<UnspentTxOut> unspentTxOuts,
    int keyIndex,
    String changeAddress,
  }) {
    BitcoinTransaction transaction = BitcoinTransaction.prepareTransaction(
        publish, this.segwitType, amount, fee, message);
    // to
    if (to.contains(':')) {
      to = to.split(':')[1];
    }
    // output
    List result = extractAddressData(to, publish);
    List<int> script = _addressDataToScript(result[0], result[1]);
    transaction.addOutput(amount, to, script);
    // input
    if (unspentTxOuts == null || unspentTxOuts.isEmpty) return null;
    Decimal utxoAmount = Decimal.zero;
    for (UnspentTxOut utxo in unspentTxOuts) {
      if (utxo.locked || !(utxo.amount > Decimal.zero) || utxo.type == null)
        continue;
      transaction.addInput(utxo, HashType.SIGHASH_ALL);
      utxoAmount += utxo.amountInSmallestUint;
    }
    if (transaction.inputs.isEmpty || utxoAmount < (amount + fee)) {
      Log.warning('Insufficient utxo amount: $utxoAmount : ${amount + fee}');
      return null;
    }
    // change, changeAddress
    Decimal change = utxoAmount - amount - fee;
    Log.debug('prepareTransaction change: $change');
    if (change > Decimal.zero) {
      List result = extractAddressData(changeAddress, publish);
      List<int> script = _addressDataToScript(result[0], result[1]);
      transaction.addOutput(change, changeAddress, script);
    }
    // Message
    List<int> msgData = (message == null) ? [] : rlp.toBuffer(message);
    Log.warning('msgData[${message.length}]: $msgData');
    // invalid msg data
    if (msgData.length > 250) {
      // TODO BitcoinCash Address condition >220
      Log.warning('Invalid msg data: ${msgData.toString()}');
      return null;
    }
    if (msgData.length > 0) {
      transaction.addData(msgData);
    }
    BitcoinTransaction signedTransaction = _signTransaction(transaction);

    // Add ChangeUtxo
    if (change > Decimal.zero) {
      UnspentTxOut changeUtxo = UnspentTxOut.fromSmallestUint(
          id: signedTransaction.txId + "-1",
          accountcurrencyId: accountcurrencyId,
          txId: signedTransaction.txId,
          vout: 1,
          type: this.segwitType == SegwitType.nonSegWit
              ? BitcoinTransactionType.WITNESS_V0_KEYHASH
              : this.segwitType == SegwitType.segWit
                  ? BitcoinTransactionType.SCRIPTHASH
                  : BitcoinTransactionType.PUBKEYHASH,
          amount: change,
          changeIndex: _Index_InternalChain,
          keyIndex: keyIndex,
          timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          locked: false,
          data: Uint8List(0),
          decimals: this.currencyDecimals);
      signedTransaction.addChangeUtxo(changeUtxo);
    }

    return signedTransaction;
  }

  Decimal calculateTransactionVSize({
    List<UnspentTxOut> unspentTxOuts,
    Decimal feePerByte,
    Decimal amount,
    Uint8List message,
  }) {
    Decimal unspentAmount = Decimal.zero;
    int headerWeight;
    int inputWeight;
    int outputWeight;
    if (this.segwitType == SegwitType.nativeSegWit) {
      headerWeight = 3 * 10 + 12;
      inputWeight = 3 * 41 + 151;
      outputWeight = 3 * 31 + 31;
    } else if (this.segwitType == SegwitType.segWit) {
      headerWeight = 3 * 10 + 12;
      inputWeight = 3 * 76 + 210;
      outputWeight = 3 * 32 + 32;
    } else {
      headerWeight = 3 * 10 + 10;
      inputWeight = 3 * 148 + 148;
      outputWeight = 3 * 34 + 34;
    }
    int numberOfTxIn = 0;
    int numberOfTxOut = message != null ? 2 : 1;
    int vsize =
        0; // 3 * base_size(excluding witnesses) + total_size(including witnesses)
    for (UnspentTxOut utxo in unspentTxOuts) {
      ++numberOfTxIn;
      unspentAmount += utxo.amount;
      vsize = ((headerWeight +
              (inputWeight * numberOfTxIn) +
              (outputWeight * numberOfTxOut) +
              3) ~/
          4);
      Decimal fee = Decimal.fromInt(vsize) * feePerByte;
      if (unspentAmount == (amount + fee)) break;

      if (unspentAmount > (amount + fee)) {
        numberOfTxOut = 3;
        vsize = ((headerWeight +
                (inputWeight * numberOfTxIn) +
                (outputWeight * numberOfTxOut) +
                3) ~/
            4);
        Decimal fee = Decimal.fromInt(vsize) * feePerByte;
        if (unspentAmount >= (amount + fee)) break;
      }
    }
    Decimal fee = Decimal.fromInt(vsize) * feePerByte;
    return fee;
  }

  Uint8List _addressDataToScript(
      BitcoinTransactionType transactionType, Uint8List data) {
    Uint8List script;
    switch (transactionType) {
      case BitcoinTransactionType.PUBKEYHASH:
      case BitcoinTransactionType.PUBKEY:
        script = toP2pkhScript(data);
        break;
      case BitcoinTransactionType.SCRIPTHASH:
        script = toP2shScript(data);
        break;
      case BitcoinTransactionType.WITNESS_V0_KEYHASH:
        script = data;
        break;
      default:
        break;
    }
    return script;
  }

  @override
  List<dynamic> extractAddressData(String address, bool publish) {
    Uint8List data;
    BitcoinTransactionType type;
    if (isP2pkhAddress(
        address,
        publish
            ? this.p2pkhAddressPrefixMainnet
            : this.p2pkhAddressPrefixTestnet)) {
      type = BitcoinTransactionType.PUBKEYHASH;
      data = decodeAddress(address).sublist(1);
    } else if (isP2shAddress(
        address,
        publish
            ? this.p2shAddressPrefixMainnet
            : this.p2shAddressPrefixTestnet)) {
      type = BitcoinTransactionType.SCRIPTHASH;
      data = decodeAddress(address).sublist(1);
    } else if (isSegWitAddress(
        address,
        publish ? this.bech32HrpMainnet : this.bech32HrpTestnet,
        bech32Separator)) {
      type = BitcoinTransactionType.WITNESS_V0_KEYHASH;
      data = extractScriptPubkeyFromSegwitAddress(address);
    } else {
      // TODO BitcoinCash Address condition
      Log.warning('unsupported Address');
    }
    return [type, data];
  }
}
