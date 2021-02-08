import 'package:floor/floor.dart';

import 'account.dart';
import 'currency.dart';

@entity
class AccountCurrency {
  @primaryKey
  @ColumnInfo(name: 'accountcurrency_id')
  final String accountcurrencyId;

  @ForeignKey(
      childColumns: ['account_id'], parentColumns: ['account_id'], entity: Account)
  @ColumnInfo(name: 'account_id')
  final String accountId;

  @ForeignKey(
    childColumns: ['currency_id'], parentColumns: ['currency_id'], entity: Currency)
  @ColumnInfo(name: 'currency_id')
  final String currencyId;

  final String balance;
  
  @ColumnInfo(name: 'number_of_used_external_key')
  final int numberOfUsedExternalKey;

  @ColumnInfo(name: 'number_of_used_internal_key')
  final int numberOfUsedInternalKey;


  @ColumnInfo(name: 'last_sync_time')
  final int lastSyncTime;


  AccountCurrency({
    this.accountcurrencyId,
    this.accountId,
    this.currencyId,
    this.balance,
    this.numberOfUsedExternalKey,
    this.numberOfUsedInternalKey,
    this.lastSyncTime,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountCurrency &&
          runtimeType == other.runtimeType &&
          accountId == other.accountId &&
          currencyId == other.currencyId &&
          balance == other.balance &&
          numberOfUsedInternalKey == other.numberOfUsedExternalKey &&
          numberOfUsedInternalKey == other.numberOfUsedInternalKey;

  @override
  int get hashCode => accountId.hashCode ^ balance.hashCode ^ numberOfUsedExternalKey.hashCode ^ numberOfUsedInternalKey.hashCode;
}
