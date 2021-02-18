import 'package:floor/floor.dart';

import 'network.dart';
import 'user.dart';

@Entity(tableName: 'Account')
class AccountEntity {
  @primaryKey
  @ColumnInfo(name: 'account_id')
  final String accountId;

  @ForeignKey(
      childColumns: ['user_id'], parentColumns: ['user_id'], entity: UserEntity)
  @ColumnInfo(name: 'user_id')
  final String userId;

  @ForeignKey(
      childColumns: ['network_id'], parentColumns: ['network_id'], entity: NetworkEntity)
  @ColumnInfo(name: 'network_id')
  final String networkId;

  // final int purpose;

  @ColumnInfo(name: 'account_index')
  final int accountIndex;

  // @ColumnInfo(name: 'curve_type')
  // final bool curveType;
  

  AccountEntity({
    this.accountId,
    this.userId,
    this.networkId,
    // this.purpose,
    this.accountIndex,
    // this.curveType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountEntity &&
          runtimeType == other.runtimeType &&
          accountId == other.accountId &&
          userId == other.userId;
          // accountIndex == other.accountIndex;

  @override
  int get hashCode => accountId.hashCode;
}
