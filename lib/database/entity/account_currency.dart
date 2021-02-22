import 'package:floor/floor.dart';

import 'account.dart';
import 'currency.dart';

@Entity(tableName: 'AccountCurrency')
class AccountCurrencyEntity {
  @primaryKey
  @ColumnInfo(name: 'accountcurrency_id', nullable: false)
  final String accountcurrencyId;

  @ForeignKey(
      childColumns: ['account_id'],
      parentColumns: ['account_id'],
      entity: AccountEntity)
  @ColumnInfo(name: 'account_id')
  final String accountId;

  @ForeignKey(
      childColumns: ['currency_id'],
      parentColumns: ['currency_id'],
      entity: CurrencyEntity)
  @ColumnInfo(name: 'currency_id')
  final String currencyId;

  final String balance;

  @ColumnInfo(name: 'number_of_used_external_key')
  final int numberOfUsedExternalKey;

  @ColumnInfo(name: 'number_of_used_internal_key')
  final int numberOfUsedInternalKey;

  @ColumnInfo(name: 'last_sync_time')
  final int lastSyncTime;

  AccountCurrencyEntity(
      {this.accountcurrencyId,
      this.accountId,
      this.currencyId,
      this.balance,
      this.numberOfUsedExternalKey,
      this.numberOfUsedInternalKey,
      this.lastSyncTime});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountCurrencyEntity &&
          runtimeType == other.runtimeType &&
          accountId == other.accountId &&
          currencyId == other.currencyId &&
          balance == other.balance &&
          numberOfUsedInternalKey == other.numberOfUsedExternalKey &&
          numberOfUsedInternalKey == other.numberOfUsedInternalKey;

  @override
  int get hashCode =>
      accountId.hashCode ^
      balance.hashCode ^
      numberOfUsedExternalKey.hashCode ^
      numberOfUsedInternalKey.hashCode;
}

@DatabaseView(
    'SELECT * FROM AccountCurrency INNER JOIN Currency ON AccountCurrency.currency_id = Currency.currency_id INNER JOIN Account ON AccountCurrency.account_id = Account.account_id INNER JOIN Network ON Account.network_id = Network.network_id',
    viewName: 'JoinCurrency')
class JoinCurrency {
  @ColumnInfo(name: 'accountcurrency_id', nullable: false)
  final String accountcurrencyId;

  final String symbol;

  @ColumnInfo(name: 'currency_id')
  final String currencyId;

  @ColumnInfo(name: 'coin_type')
  final int coinType;

  @ColumnInfo(name: 'account_index')
  final int accountIndex;

  // final int purpose;

  final String balance;

  final String name;

  final String image;

  @ColumnInfo(name: 'network_id')
  final String blockchainId;

  @ColumnInfo(name: 'chain_id')
  final int chainId;

  final bool publish;

  final String contract;

  final int decimals;

  final String type;

  JoinCurrency(
      {this.accountcurrencyId,
      this.currencyId,
      this.symbol,
      this.name,
      this.balance,
      this.accountIndex,
      this.coinType,
      this.image,
      this.blockchainId,
      this.chainId,
      this.publish,
      this.contract,
      this.decimals,
      this.type});
}
