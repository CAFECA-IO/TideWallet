import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:decimal/decimal.dart';

import '../helpers/bitcoin_base_extension.dart';
import '../helpers/logger.dart';
import '../helpers/converter.dart';
import '../helpers/utils.dart';
import 'transaction.model.dart';
import 'db_transaction.model.dart';
import 'utxo.model.dart';

enum BitcoinTransactionType {
  PUBKEYHASH,
  SCRIPTHASH,
  WITNESS_V0_KEYHASH,
  PUBKEY
}

extension BitcoinTransactionTypeExt on BitcoinTransactionType {
  String get value {
    switch (this) {
      case BitcoinTransactionType.PUBKEYHASH:
        return "pubkeyhash";
      case BitcoinTransactionType.SCRIPTHASH:
        return "scripthash";
      case BitcoinTransactionType.WITNESS_V0_KEYHASH:
        return "witness_v0_keyhash";
      case BitcoinTransactionType.PUBKEY:
        return "pubkey";
        break;
    }
  }
}

enum SegWitType { nonSegWit, segWit, nativeSegWit }

extension SegWitTypeExt on SegWitType {
  int get value {
    switch (this) {
      case SegWitType.nonSegWit:
        return 1;
      case SegWitType.segWit:
        return 2;
      case SegWitType.nativeSegWit:
        return 3;
    }
  }

  int get purpose {
    switch (this) {
      case SegWitType.nonSegWit:
        return (0x80000000 | 44);
      case SegWitType.segWit:
        return (0x80000000 | 49);
      case SegWitType.nativeSegWit:
        return (0x80000000 | 84);
    }
  }

  String get name {
    switch (this) {
      case SegWitType.nonSegWit:
        return "Legacy";
      case SegWitType.segWit:
        return "SegWit";
      case SegWitType.nativeSegWit:
        return "Native SegWit";
    }
  }
}

enum HashType {
  SIGHASH_ALL,
  SIGHASH_NONE,
  SIGHASH_SINGLE,
  SIGHASH_ANYONECANPAY
}

extension HashTypeExt on HashType {
  int get value {
    switch (this) {
      case HashType.SIGHASH_ALL:
        return 0x01;
        break;
      case HashType.SIGHASH_NONE:
        return 0x02;
        break;
      case HashType.SIGHASH_SINGLE:
        return 0x03;
        break;
      case HashType.SIGHASH_ANYONECANPAY:
        return 0x80;
        break;
    }
  }
}

class Input {
  /* hash of the Transaction whose output is being used */
  // Uint8List prevTxHash;
  /* used output's index in the previous transaction */
  // int vout;
  /* the signature produced to check validity */
  final UnspentTxOut utxo;
  Uint8List scriptSig;
  int sequence;
  final Uint8List publicKey;
  final HashType hashType;

  Input(this.utxo, this.publicKey, this.hashType);
  bool segwit = false;

  Uint8List get reservedTxid =>
      Uint8List.fromList(hex.decode(this.utxo.txid).reversed.toList());
  Uint8List get voutInBuffer => Uint8List(4)
    ..buffer.asByteData().setUint32(0, this.utxo.vout, Endian.little);
  Uint8List get sequenceInBuffer => Uint8List(4)
    ..buffer.asByteData().setUint32(0, this.utxo.sequence, Endian.little);
  Uint8List get amountInBuffer => Uint8List(8)
    ..buffer.asByteData().setUint64(0,
        Converter.toBtcSmallestUnit(this.utxo.amount).toInt(), Endian.little);

  Uint8List get hashTypeInBuffer => Uint8List(4)
    ..buffer.asByteData().setUint32(0, hashType.value, Endian.little);

  bool isSegwit(SegWitType segWitType) {
    bool segwit = false;
    if (this.utxo.type == BitcoinTransactionType.PUBKEYHASH.value) {
      // do nothing
    } else if (this.utxo.type == BitcoinTransactionType.SCRIPTHASH.value) {
      segwit = (segWitType == SegWitType.segWit);
    } else if (this.utxo.type ==
        BitcoinTransactionType.WITNESS_V0_KEYHASH.value) {
      segwit = true;
    } else if (this.utxo.type == 'pubkey') {
      // do nothing
    } else {
      Log.warning('Unusable this.utxo: ${this.utxo.txid}');
      return null;
    }
    this.segwit = segwit;
    return segwit;
  }

  void addSignature(Uint8List signature) {
    if (signature == null)
      scriptSig = null;
    else {
      BitcoinTransactionType utxoType = BitcoinTransactionType.values
          .firstWhere((txType) => this.utxo.type == txType.value);
      switch (utxoType) {
        case BitcoinTransactionType.PUBKEYHASH:
          scriptSig = Uint8List.fromList([
            signature.length,
            ...signature,
            this.publicKey.length,
            ...this.publicKey
          ]);
          break;
        case BitcoinTransactionType.SCRIPTHASH:
          scriptSig = Uint8List.fromList([
            0x00,
            signature.length,
            ...signature,
            this.publicKey.length,
            ...this.publicKey
          ]);
          break;
        case BitcoinTransactionType.WITNESS_V0_KEYHASH:
          scriptSig = Uint8List.fromList([
            0x02,
            signature.length,
            ...signature,
            this.publicKey.length,
            ...this.publicKey
          ]);
          break;
        case BitcoinTransactionType.PUBKEY:
          scriptSig = Uint8List.fromList([
            signature.length,
            ...signature,
          ]);
          break;
      }
    }
  }
}

class Output {
  /* value in bitcoins of the output (inSatoshi)*/
  final Decimal amount; // inBtc
  /* the address or public key of the recipient */
  final String address;
  final Uint8List script;

  Output(this.amount, this.address, this.script);

  Uint8List get amountInBuffer => Uint8List(8)
    ..buffer.asByteData().setUint64(
        0, Converter.toBtcSmallestUnit(this.amount).toInt(), Endian.little);
}

class BitcoinTransaction extends Transaction {
  static const int ADVANCED_TRANSACTION_MARKER = 0x00;
  static const int ADVANCED_TRANSACTION_FLAG = 0x01;
  static const int DEFAULT_SEQUENCE = 0xffffffff;

  String id;
  String currencyId;
  String txid;
  int locktime;
  int timestamp;
  int confirmations;
  TransactionDirection direction;
  TransactionStatus status;
  String sourceAddresses; // TODO
  String destinationAddresses; //TODO
  Decimal amount;
  String fee;
  Uint8List note;

  List<Input> _inputs;
  List<Output> _outputs;
  Uint8List _version;
  Uint8List _lockTime;
  SegWitType _segWitType;
  // bool _publish; //TODO get publish property from currency

  List<Input> get inputs => this._inputs;

  BitcoinTransaction({
    this.id,
    this.currencyId,
    this.txid,
    this.locktime,
    this.timestamp,
    this.confirmations,
    this.direction,
    this.status,
    this.sourceAddresses,
    this.destinationAddresses,
    this.amount,
    this.fee,
    this.note,
  });

  BitcoinTransaction.fromMap(Map<String, dynamic> transactionMap)
      : id = transactionMap[DBTransaction.FieldName_Id],
        currencyId = transactionMap[DBTransaction.FieldName_CurrencyId],
        txid = transactionMap[DBTransaction.FieldName_TxId],
        sourceAddresses =
            transactionMap[DBTransaction.FieldName_SourceAddresses],
        destinationAddresses =
            transactionMap[DBTransaction.FieldName_DesticnationAddresses],
        timestamp = transactionMap[DBTransaction.FieldName_Timestamp],
        confirmations = transactionMap[DBTransaction.FieldName_Confirmations],
        amount = transactionMap[DBTransaction.FieldName_Amount],
        direction = TransactionDirection.values.firstWhere((element) =>
            element.value == transactionMap[DBTransaction.FieldName_Direction]),
        locktime = transactionMap[DBTransaction.FieldName_LockedTime],
        fee = transactionMap[DBTransaction.FieldName_Fee].toString(),
        note = transactionMap[DBTransaction.FieldName_Note],
        status = transactionMap[DBTransaction.FieldName_Status];

  BitcoinTransaction.prepareTransaction(bool publish, SegWitType segwitType,
      {int lockTime}) // in Satoshi
      : _segWitType = segwitType {
    _inputs = List<Input>();
    _outputs = List<Output>();
    _segWitType = segwitType ?? SegWitType.nonSegWit;
    setVersion(publish ? 1 : 2);
    setlockTime(lockTime ?? 0);
  }

  void setVersion(int version) {
    _version = Uint8List(4)
      ..buffer.asByteData().setUint32(0, version, Endian.little);
    Log.verbose('_version: $_version');
  }

  void setlockTime(int locktime) {
    _lockTime = Uint8List(4)
      ..buffer.asByteData().setUint32(0, locktime, Endian.little);
    Log.verbose('_lockTime: $_lockTime');
  }

  void addInput(UnspentTxOut utxo, Uint8List publicKey, HashType hashType) {
    Input input = Input(utxo, publicKey, hashType);
    _inputs.add(input);
  }

  void addOutput(
    Decimal amount,
    String address,
    List<int> script,
  ) {
    if (script == null || script.length == 0) return null;
    List<int> scriptLength;
    if (script.length < 0xFD) {
      scriptLength = [script.length];
    } else if (script.length <= 0xFFFF) {
      List<int> scriptLengthData = (Uint8List(2)
            ..buffer.asByteData().setUint32(0, script.length, Endian.little))
          .toList();
      scriptLength = [0xFD] + scriptLengthData;
    } else {
      Log.warning(' unsupported script length');
      return null;
    }
    Output output =
        Output(amount, address, Uint8List.fromList(scriptLength + script));
    _outputs.add(output);
  }

  void addData(List<int> data) {
    int scriptLength = data.length + 2;
    Output output = Output(Decimal.zero, '',
        Uint8List.fromList([scriptLength, 0x6a, data.length, ...data]));
    _outputs.add(output);
  }

  Uint8List getRawDataToSign(int index) {
    List<int> data = [];
    Input selectedInput = this._inputs[index];
    if (selectedInput.isSegwit(this._segWitType)) {
      //  nVersion
      //  hashPrevouts
      //  hashSequence
      //  outpoint:     (32-byte hash + 4-byte little endian vout)
      //  scriptCode:   For P2WPKH witness program, the scriptCode is 0x1976a914{20-byte-pubkey-hash}88ac. //only compressed public keys are accepted in P2WPKH and P2WSH.
      //  amount:       value of the output spent by this input (8-byte little endian)
      //  nSequence:    ffffffff
      //  hashOutputs
      //  nLockTime:    11000000
      //  nHashType:    01000000 // SIGHASH_ALL

      List<int> prevouts = [];
      List<int> sequences = [];
      List<int> outputs = [];
      for (Input input in this._inputs) {
        prevouts.addAll(input.reservedTxid + input.voutInBuffer);
        sequences.addAll(input.sequenceInBuffer);
      }

      if (selectedInput.hashType != HashType.SIGHASH_SINGLE ||
          selectedInput.hashType != HashType.SIGHASH_NONE)
        for (Output output in this._outputs) {
          outputs.addAll(output.amountInBuffer + output.script);
        }
      else if (selectedInput.hashType == HashType.SIGHASH_SINGLE &&
          index < this._outputs.length)
        outputs.addAll(
            this._outputs[index].amountInBuffer + this._outputs[index].script);

      List<int> hashPrevouts = sha256(sha256(prevouts));
      List<int> hashSequence = sha256(sha256(sequences));

      Log.verbose('hashPrevouts: ${hex.encode(hashPrevouts)}');
      Log.verbose('hashSequence: ${hex.encode(hashSequence)}');

      //  nVersion
      data.addAll(this._version);
      //  hashPrevouts
      /* 
      If the ANYONECANPAY flag is not set, hashPrevouts is the double SHA256 of the serialization of all input outpoints;
      Otherwise, hashPrevouts is a uint256 of 0x0000......0000.
      */
      if (selectedInput.hashType != HashType.SIGHASH_ANYONECANPAY)
        data.addAll(hashPrevouts);
      else
        data.addAll(
            Uint8List(32)..buffer.asByteData().setUint32(0, 0, Endian.little));

      //  hashSequence
      /* 
      If none of the ANYONECANPAY, SINGLE, NONE sighash type is set, hashSequence is the double SHA256 of the serialization of nSequence of all inputs;
      Otherwise, hashSequence is a uint256 of 0x0000......0000.
       */
      if (selectedInput.hashType == HashType.SIGHASH_ALL)
        data.addAll(hashSequence);
      else
        data.addAll(
            Uint8List(32)..buffer.asByteData().setUint32(0, 0, Endian.little));
      //  outpoint:
      data.addAll(selectedInput.reservedTxid + selectedInput.voutInBuffer);
      /*
      For P2WPKH witness program, the scriptCode is 0x1976a914{20-byte-pubkey-hash}88ac.
      For P2WSH witness program,
          if the witnessScript does not contain any OP_CODESEPARATOR, the scriptCode is the witnessScript serialized as scripts inside CTxOut.
          if the witnessScript contains any OP_CODESEPARATOR, the scriptCode is the witnessScript but removing everything up to and including 
          the last executed OP_CODESEPARATOR before the signature checking opcode being executed, serialized as scripts inside CTxOut. 
          (The exact semantics is demonstrated in the examples below)
       */
      //  scriptCode:
      List<int> scriptCode =
          pubKeyHashToP2pkhScript(toPubKeyHash(selectedInput.publicKey));
      Log.verbose(
          'prevOutScript: ${hex.encode([scriptCode.length, ...scriptCode])}');
      data.addAll([scriptCode.length, ...scriptCode]);

      //  amount:
      data.addAll(selectedInput.amountInBuffer);
      //  nSequence:
      data.addAll(selectedInput.sequenceInBuffer);
      //  hashOutputs
      /*
      If the sighash type is neither SINGLE nor NONE, hashOutputs is the double SHA256 of the serialization of all output amount (8-byte little endian) with scriptPubKey (serialized as scripts inside CTxOuts);
      If sighash type is SINGLE and the input index??  is smaller than the number of outputs, hashOutputs is the double SHA256 of the output amount with scriptPubKey of the same index as the input;
      Otherwise, hashOutputs is a uint256 of 0x0000......0000.
      */
      if (outputs.isNotEmpty) {
        Log.debug('outputs: ${hex.encode(outputs)}');
        List<int> hashOutputs = sha256(sha256(outputs));
        data.addAll(hashOutputs);
        Log.verbose('hashOutputs: ${hex.encode(hashOutputs)}');
      } else
        data.addAll(
            Uint8List(32)..buffer.asByteData().setUint32(0, 0, Endian.little));

      //  nLockTime:
      data.addAll(this._lockTime);
      //  nHashType:
      data.addAll(selectedInput.hashTypeInBuffer);
    } else {
      //  nVersion
      data.addAll(this._version);
      // Input count
      data.add(this._inputs.length);
      for (Input input in this._inputs) {
        //  outpoint:
        data.addAll(input.reservedTxid + input.voutInBuffer);
        if (input == selectedInput) {
          //  txin:
          List<int> script;
          if (input.utxo.type == BitcoinTransactionType.PUBKEYHASH.value) {
            script = pubKeyHashToP2pkhScript(toPubKeyHash(input.publicKey));
          } else if (input.utxo.type == BitcoinTransactionType.PUBKEY.value) {
            script = pubkeyToP2PKScript(input.publicKey);
          } else if (input.utxo.type ==
              BitcoinTransactionType.SCRIPTHASH.value) {
            script = pubkeyToBIP49RedeemScript(input.publicKey);
          } else if (input.utxo.type ==
              BitcoinTransactionType.WITNESS_V0_KEYHASH.value) {
            // do nothing
          } else {
            Log.warning('Unusable utxo: ${input.utxo.txid}');
            return null;
          }
          data.addAll(script);
        } else {
          data.add(0);
        }
        //  nSequence:
        data.addAll(selectedInput.sequenceInBuffer);
      }
      // Output count
      data.add(this._outputs.length);
      Log.debug('this._outputs.length: ${this._outputs.length}');

      for (Output output in this._outputs) {
        Log.debug(
            'output amountInBuffer: ${hex.encode(output.amountInBuffer)}');
        Log.debug('output script: ${hex.encode(output.script)}');

        data.addAll(output.amountInBuffer + output.script);
      }
      //  nLockTime:
      data.addAll(this._lockTime);
    }
    return Uint8List.fromList(data);
  }

  Uint8List get serializeTransaction {
    List<int> data = [];
    //  nVersion
    data.addAll(this._version);

    // Input count
    data.add(this._inputs.length);

    // Input
    bool segwit = false;
    for (Input input in this._inputs) {
      data.addAll(input.reservedTxid + input.voutInBuffer);
      if (input.isSegwit(this._segWitType)) {
        segwit = true;
        if (input.utxo.type == BitcoinTransactionType.SCRIPTHASH.value)
          data.addAll([input.utxo.data.length, ...input.utxo.data]);
        else
          data.add(0);
      } else {
        input.scriptSig != null ? data.addAll(input.scriptSig) : data.add(0);
      }
      data.addAll(input.sequenceInBuffer);
    }
    // Output count
    data.add(this._outputs.length);

    // Output
    for (Output output in this._outputs) {
      data.addAll(output.amountInBuffer + output.script);
    }
    // txid
    this.txid = hex
        .encode(sha256(sha256([...data, ...this._lockTime])).reversed.toList());

    //witness
    if (segwit) {
      for (Input input in this._inputs) {
        if (input.isSegwit(this._segWitType)) {
          if (input.scriptSig != null) {
            data.addAll(input.scriptSig);
          }
        } else {
          data.add(0);
        }
      }
      data.insertAll(
          4, [ADVANCED_TRANSACTION_MARKER, ADVANCED_TRANSACTION_FLAG]);
    }

    //  nLockTime:
    data.addAll(this._lockTime);

    return Uint8List.fromList(data);
  }

  Uint8List get transactionHash {
    return sha256(sha256(serializeTransaction));
  }
}
