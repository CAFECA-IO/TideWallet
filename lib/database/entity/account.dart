import 'package:floor/floor.dart';

import 'user.dart';

@entity
class Account {
  @primaryKey
  @ColumnInfo(name: 'account_id')
  final String accountId;

  @ForeignKey(
      childColumns: ['user_id'], parentColumns: ['user_id'], entity: User)
  @ColumnInfo(name: 'user_id')
  final String userId;

  final int purpose;

  @ColumnInfo(name: 'account_index')
  final int accountIndex;

  @ColumnInfo(name: 'curve_type')
  final bool curveType;

  Account(
      {this.accountId,
      this.userId,
      this.purpose,
      this.accountIndex,
      this.curveType});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Account &&
          runtimeType == other.runtimeType &&
          accountId == other.accountId &&
          userId == other.userId &&
          accountIndex == other.accountIndex;

  @override
  int get hashCode => accountId.hashCode;
}
