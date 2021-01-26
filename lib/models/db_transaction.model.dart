import 'dart:typed_data';

import 'transaction.model.dart';
import 'bitcoin_transaction.model.dart';
import 'ethereum_token_transaction.model.dart';
import 'ethereum_transaction.model.dart';

class DBTransaction {
  static const String ClassName = "_transaction";
  static const String FieldName_Id = "id";
  static const String FieldName_Network = "network";
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
  static const String FieldName_TokenId = "token_id"; // token
  static const String FieldName_BlockHeight = "block_height"; //ripple
  static const String FieldName_Status = "status"; //ripple
  static const String FieldName_TxType = "txType"; //ripple
  static const String FieldName_Direction = "direction"; // Btc
  static const String FieldName_LockedTime = "locktime"; // Btc
  static const String FieldName_Fee = "fee"; // Btc
  static const String FieldName_Note = "note"; // Btc, Eth
  static const String FieldName_OwnerAddress = "owner_address"; // Eth, token
  static const String FieldName_OwnerContract = "owner_contract";
  static const String FieldName_ConfirmedTime = "confirmed_time";

  String _id;
  int _network;
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
  String _tokenId;
  int _blockHeight;
  String _txType;
  TransactionDirection _direction;
  int _locktime;
  String _fee; // in coinUnit
  Uint8List _note;
  String _ownerAddress;
  String _ownerContract;
  int _confirmedTime;
  TransactionStatus _status;

  Map<String, dynamic> get map => {
        FieldName_Id: _id,
        FieldName_Network: _network,
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
        FieldName_TokenId: _tokenId,
        FieldName_BlockHeight: _blockHeight,
        FieldName_Status: _status,
        FieldName_TxType: _txType,
        FieldName_Direction: _direction.value,
        FieldName_LockedTime: _locktime,
        FieldName_Fee: _fee,
        FieldName_Note: _note,
        FieldName_OwnerAddress: _ownerAddress,
        FieldName_OwnerContract: _ownerContract,
        FieldName_ConfirmedTime: _confirmedTime
      };

  DBTransaction(
      {String id,
      int network,
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
      String tokenId,
      int blockHeight,
      TransactionStatus status,
      String txType,
      TransactionDirection direction,
      int locktime,
      String fee,
      Uint8List note,
      String ownerAddress,
      String ownerContract,
      int confirmedTime})
      : _id = id,
        _network = network,
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
        _tokenId = tokenId,
        _blockHeight = blockHeight,
        _status = status,
        _txType = txType,
        _direction = direction,
        _locktime = locktime,
        _fee = fee,
        _note = note,
        _ownerAddress = ownerAddress,
        _ownerContract = ownerContract,
        _confirmedTime = confirmedTime;

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
        _tokenId = null,
        _blockHeight = null,
        _status = transaction.status,
        _txType = null,
        _direction = transaction.direction,
        _locktime = transaction.locktime,
        _fee = transaction.fee,
        _note = transaction.note,
        _ownerAddress = null,
        _ownerContract = null;

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
        _tokenId = transaction.tokenId,
        _blockHeight = null,
        _status = transaction.status,
        _txType = null,
        _direction = null,
        _locktime = null,
        _fee = null,
        _note = null,
        _ownerAddress = transaction.ownerAddress,
        _ownerContract = transaction.ownerContract;

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
        _tokenId = null,
        _blockHeight = null,
        _status = transaction.status,
        _txType = null,
        _direction = null,
        _locktime = null,
        _fee = null,
        _note = null,
        _ownerAddress = transaction.ownerAddress,
        _ownerContract = null;
}
