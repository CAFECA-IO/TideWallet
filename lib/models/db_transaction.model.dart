import 'dart:typed_data';

import 'transaction.model.dart';
import 'bitcoin_transaction.model.dart';
import 'ethereum_token_transaction.model.dart';
import 'ethereum_transaction.model.dart';

class DBTransaction {
  static const String ClassName = "_transaction";
  static const String FieldName_Id = "id";
  static const String FieldName_AccountId = "account_id";
  static const String FieldName_CurrencyId = "currency_id";
  static const String FieldName_TxId = "txid"; // txHash
  static const String FieldName_SourceAddresses =
      "source_addresses"; // String to List, seperate by ","
  static const String FieldName_DesticnationAddresses =
      "desticnation_addresses"; // String to List, seperate by ","
  static const String FieldName_Timestamp = "tx_timestamp";
  static const String FieldName_Confirmations = "confirmations";
  static const String FieldName_Amount = "amount";
  static const String FieldName_GasPrice = "gas_price"; // Eth
  static const String FieldName_GasUsed = "gas_used"; // Eth
  static const String FieldName_Nonce = "nonce"; // Eth
  static const String FieldName_Block = "block"; // Eth
  static const String FieldName_BlockHeight = "block_height"; //ripple
  static const String FieldName_TxType = "txType"; //ripple
  static const String FieldName_Direction = "direction"; // Btc
  static const String FieldName_LockedTime = "locktime"; // Btc
  static const String FieldName_Fee = "fee"; // Btc
  static const String FieldName_Note = "note"; // Btc, Eth
  static const String FieldName_Status = "status";

  String _id;
  String _accountId;
  String _currencyId;
  String _txId;
  String _sourceAddresses;
  String _destinationAddresses;
  int _timestamp; // in second
  int _confirmations;
  String _amount; // in coinUnit
  String _gasPrice;
  int _gasUsed;
  int _nonce;
  int _block; // in second
  int _blockHeight;
  String _txType;
  TransactionDirection _direction;
  int _locktime;
  String _fee; // in coinUnit
  Uint8List _note;
  TransactionStatus _status;

  Map<String, dynamic> get map => {
        FieldName_Id: _id,
        FieldName_AccountId: _accountId,
        FieldName_CurrencyId: _currencyId,
        FieldName_TxId: _txId,
        FieldName_SourceAddresses: _sourceAddresses,
        FieldName_DesticnationAddresses: _destinationAddresses,
        FieldName_Timestamp: _timestamp,
        FieldName_Confirmations: _confirmations,
        FieldName_Amount: _amount,
        FieldName_GasPrice: _gasPrice,
        FieldName_GasUsed: _gasUsed,
        FieldName_Nonce: _nonce,
        FieldName_Block: _block,
        FieldName_BlockHeight: _blockHeight,
        FieldName_Status: _status,
        FieldName_TxType: _txType,
        FieldName_Direction: _direction.value,
        FieldName_LockedTime: _locktime,
        FieldName_Fee: _fee,
        FieldName_Note: _note
      };

  DBTransaction(
      {String id,
      String accountId,
      String currencyId,
      String txId,
      String sourceAddresses,
      String destinationAddresses,
      int timestamp,
      int confirmations,
      String amount,
      String gasPrice,
      int gasUsed,
      int nonce,
      int block,
      int blockHeight,
      TransactionStatus status,
      String txType,
      TransactionDirection direction,
      int locktime,
      String fee,
      Uint8List note})
      : _id = id,
        _accountId = accountId,
        _currencyId = currencyId,
        _txId = txId,
        _sourceAddresses = sourceAddresses,
        _destinationAddresses = destinationAddresses,
        _timestamp = timestamp,
        _confirmations = confirmations,
        _amount = amount,
        _gasPrice = gasPrice,
        _gasUsed = gasUsed,
        _nonce = nonce,
        _block = block,
        _blockHeight = blockHeight,
        _status = status,
        _txType = txType,
        _direction = direction,
        _locktime = locktime,
        _fee = fee,
        _note = note;

  DBTransaction.fromBitcoinTransaction(
    BitcoinTransaction transaction,
  )   : _id = transaction.id,
        _txId = transaction.txid,
        _sourceAddresses = transaction.sourceAddresses,
        _destinationAddresses = transaction.destinationAddresses,
        _timestamp = transaction.timestamp,
        _confirmations = transaction.confirmations,
        _amount = transaction.amount,
        _gasPrice = null,
        _gasUsed = null,
        _nonce = null,
        _block = null,
        _blockHeight = null,
        _status = transaction.status,
        _txType = null,
        _direction = transaction.direction,
        _locktime = transaction.locktime,
        _fee = transaction.fee,
        _note = transaction.note;

  DBTransaction.fromEthereumTokenTransaction(
      EthereumTokenTransaction transaction)
      : _id = transaction.id,
        _txId = transaction.txHash,
        _sourceAddresses = transaction.from,
        _destinationAddresses = transaction.to,
        _timestamp = transaction.timestamp,
        _confirmations = transaction.confirmations,
        _amount = transaction.amount,
        _gasPrice = null,
        _gasUsed = null,
        _nonce = null,
        _block = null,
        _blockHeight = null,
        _status = transaction.status,
        _txType = null,
        _direction = null,
        _locktime = null,
        _fee = null,
        _note = null;

  DBTransaction.fromEthereumTransaction(EthereumTransaction transaction)
      : _id = transaction.id,
        _txId = transaction.txHash,
        _sourceAddresses = transaction.from,
        _destinationAddresses = transaction.to,
        _timestamp = transaction.timestamp,
        _confirmations = transaction.confirmations,
        _amount = transaction.amount,
        _gasPrice = transaction.gasPrice,
        _gasUsed = transaction.gasUsed,
        _nonce = transaction.nonce,
        _block = transaction.block,
        _blockHeight = null,
        _status = transaction.status,
        _txType = null,
        _direction = null,
        _locktime = null,
        _fee = null,
        _note = null;
}
