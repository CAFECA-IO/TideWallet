import 'dart:typed_data';
import 'package:decimal/decimal.dart';
import 'package:convert/convert.dart';

import 'transaction_service.dart';
import '../cores/signer.dart';
import '../helpers/utils.dart';
import '../models/utxo.model.dart';
import '../models/bitcoin_transaction.model.dart';
import '../helpers/bitcoin_base_extension.dart';
import '../helpers/logger.dart';
import '../helpers/rlp.dart' as rlp;

class BitcoinBasedTransactionServiceDecorator extends TransactionService {
  final TransactionService service;
  int p2pkhAddressPrefixTestnet;
  int p2pkhAddressPrefixMainnet;
  int p2shAddressPrefixTestnet;
  int p2shAddressPrefixMainnet;
  String bech32HrpMainnet;
  String bech32HrpTestnet;
  String bech32Separator;
  SegWitType segWitType;
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

  Uint8List _signTransaction(BitcoinTransaction transaction) {
    int index = 0;
    while (index < transaction.inputs.length) {
      Uint8List rawData = transaction.getRawDataToSign(index);
      Uint8List rawDataHash = sha256(sha256(rawData));
      Log.debug('rawData: ${hex.encode(rawData)}');
      Log.debug('rawDataHash: ${hex.encode(rawDataHash)}');
      UnspentTxOut utxo = transaction.inputs[index].utxo;

      // !! TODO get privateKey
      // MsgSignature sig = Signer().sign(
      //     rawDataHash,
      //     this.hdWallet.getExtendedPrivateKey(this.account.path,
      //         chainIndex: utxo.chainIndex, keyIndex: utxo.keyIndex));

      Uint8List buffer = new Uint8List(64);

      // buffer.setRange(0, 32, encodeBigInt(sig.r));
      // buffer.setRange(32, 64, encodeBigInt(sig.s));

      Uint8List signature = Signer()
          .encodeSignature(buffer, transaction.inputs[index].hashType.value);
      Log.debug('signature: $signature');
      Log.debug('signature hex: ${hex.encode(signature)}');
      Log.debug(
          'publicKey hex: ${hex.encode(transaction.inputs[index].publicKey)}');

      transaction.inputs[index].addSignature(signature);
      index++;
    }
    Uint8List signedTransaction = transaction.serializeTransaction;
    return signedTransaction;
  }

  @override
  Future<Uint8List> prepareTransaction(
      bool publish, String to, Decimal amount, Decimal fee, Uint8List message,
      {List<UnspentTxOut> unspentTxOuts, String changeAddress}) async {
    BitcoinTransaction transaction =
        BitcoinTransaction.prepareTransaction(publish, this.segWitType);
    // amount,to
    if (to.contains(':')) {
      to = to.split(':')[1];
    }
    // output
    List<int> script;
    if (isP2pkhAddress(
        to,
        publish
            ? this.p2pkhAddressPrefixMainnet
            : this.p2pkhAddressPrefixTestnet)) {
      script = pubKeyHashToP2pkhScript(decodeAddress(to).sublist(1));
    } else if (isP2shAddress(
        to,
        publish
            ? this.p2shAddressPrefixMainnet
            : this.p2shAddressPrefixTestnet)) {
      script = pubKeyHashToP2shScript(decodeAddress(to).sublist(1));
    } else if (isSegWitAddress(
        to,
        publish ? this.bech32HrpMainnet : this.bech32HrpTestnet,
        bech32Separator)) {
      script = extractScriptPubkeyFromSegwitAddress(to);
    } else {
      // TODO BitcoinCash Address condition
      Log.warning('unsupported Address');
    }
    transaction.addOutput(amount, to, script);
    // input
    if (unspentTxOuts == null || unspentTxOuts.isEmpty) return Uint8List(0);
    Decimal utxoAmount = Decimal.zero;
    for (UnspentTxOut utxo in unspentTxOuts) {
      if (utxo.locked != 0 || !(utxo.amount > Decimal.zero) || utxo.type == '')
        continue;

      // !! TODO get publicKey
      // List<int> publicKey = this.hdWallet.getExtendedPublicKey(
      //     this.account.path,
      //     chainIndex: utxo.chainIndex,
      //     keyIndex: utxo.keyIndex);
      // transaction.addInput(utxo, publicKey, HashType.SIGHASH_ALL);

      utxoAmount += utxo.amount;
      if (utxoAmount >= (amount + fee)) break;
    }
    if (transaction.inputs.isEmpty || utxoAmount < (amount + fee)) {
      Log.warning('Insufficient utxo amount: $utxoAmount : ${amount + fee}');
      return Uint8List(0);
    }
    // change, changeAddress
    Decimal change = utxoAmount - amount - fee;
    if (change > Decimal.zero) {
      List<int> script;
      if (isP2pkhAddress(
          changeAddress,
          publish
              ? this.p2pkhAddressPrefixMainnet
              : this.p2pkhAddressPrefixTestnet)) {
        script = pubKeyHashToP2pkhScript(decodeAddress(to).sublist(1));
      } else if (isP2shAddress(
          changeAddress,
          publish
              ? this.p2shAddressPrefixMainnet
              : this.p2shAddressPrefixTestnet)) {
        script = pubKeyHashToP2shScript(decodeAddress(to).sublist(1));
      } else if (isSegWitAddress(
          changeAddress,
          publish ? this.bech32HrpMainnet : this.bech32HrpTestnet,
          bech32Separator)) {
        script = extractScriptPubkeyFromSegwitAddress(to);
      } else {
        // TODO BitcoinCash Address condition
        Log.warning('unsupported Address');
      }
      transaction.addOutput(change, changeAddress, script);
    }
    // Message
    List<int> msgData = (message == null) ? [] : rlp.toBuffer(message);
    Log.warning('msgData[$message]: $msgData');
    // invalid msg data
    if (msgData.length > 250) {
      // TODO BitcoinCash Address condition >220
      Log.warning('Invalid msg data: ${msgData.toString()}');
      return Uint8List(0);
    }
    if (msgData.length > 0) {
      transaction.addData(msgData);
    }
    // TODO save ChangeUtxo
    return _signTransaction(transaction);
  }
}
