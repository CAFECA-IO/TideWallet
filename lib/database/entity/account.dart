import 'package:floor/floor.dart';

import 'user.dart';
import 'network.dart';
import 'currency.dart';

@Entity(
  tableName: 'Account',
  foreignKeys: [
    ForeignKey(
      childColumns: ['user_id'],
      parentColumns: ['user_id'],
      entity: UserEntity,
      onDelete: ForeignKeyAction.cascade,
    ),
    ForeignKey(
      childColumns: ['blockchain_id'],
      parentColumns: ['blockchain_id'],
      entity: NetworkEntity,
      onDelete: ForeignKeyAction.cascade,
    ),
    ForeignKey(
      childColumns: ['currency_id'],
      parentColumns: ['currency_id'],
      entity: CurrencyEntity,
      onDelete: ForeignKeyAction.cascade,
    ),
  ],
)
class AccountEntity {
  @primaryKey
  final String id;

  @ColumnInfo(name: 'share_account_id')
  final String shareAccountId;

  @ColumnInfo(name: 'user_id')
  final String userId;

  @ColumnInfo(name: 'blockchain_id')
  final String blockchainId;

  @ColumnInfo(name: 'currency_id')
  final String currencyId;

  final int purpose;

  @ColumnInfo(name: 'account_coin_type')
  final int accountCoinType;

  @ColumnInfo(name: 'account_index')
  final int accountIndex;

  @ColumnInfo(name: 'curve_type')
  final int curveType;

  final String balance;

  @ColumnInfo(name: 'number_of_used_external_key')
  int? numberOfUsedExternalKey;

  @ColumnInfo(name: 'number_of_used_internal_key')
  int? numberOfUsedInternalKey;

  @ColumnInfo(name: 'last_sync_time')
  int? lastSyncTime;

  AccountEntity(
      {required this.id,
      required this.shareAccountId,
      required this.userId,
      required this.blockchainId,
      required this.currencyId,
      required this.purpose,
      required this.accountCoinType,
      required this.accountIndex,
      required this.curveType,
      required this.balance,
      required this.numberOfUsedExternalKey,
      required this.numberOfUsedInternalKey,
      required this.lastSyncTime});

  AccountEntity copyWith(
      {String? id,
      String? shareAccountId,
      String? userId,
      String? blockchainId,
      String? currencyId,
      int? purpose,
      int? accountCoinType,
      int? accountIndex,
      int? curveType,
      String? balance,
      int? numberOfUsedExternalKey,
      int? numberOfUsedInternalKey,
      int? lastSyncTime}) {
    return AccountEntity(
        id: id ?? this.id,
        shareAccountId: shareAccountId ?? this.shareAccountId,
        userId: userId ?? this.userId,
        blockchainId: blockchainId ?? this.blockchainId,
        currencyId: currencyId ?? this.currencyId,
        purpose: purpose ?? this.purpose,
        accountCoinType: accountCoinType ?? this.accountCoinType,
        accountIndex: accountIndex ?? this.accountIndex,
        curveType: curveType ?? this.curveType,
        balance: balance ?? this.balance,
        numberOfUsedExternalKey:
            numberOfUsedExternalKey ?? this.numberOfUsedExternalKey,
        numberOfUsedInternalKey:
            numberOfUsedInternalKey ?? this.numberOfUsedInternalKey,
        lastSyncTime: lastSyncTime ?? this.lastSyncTime);
  }

  AccountEntity.fromAccountJson(Map json, String shareAccountId, String userId,
      {int? timestamp})
      : id = json['account_id'] ??
            json['account_token_id'], // ++ debugInfo: Change name
        shareAccountId = shareAccountId,
        userId = userId,
        blockchainId = json['blockchain_id'],
        currencyId = json['currency_id'] ?? json['token_id'],
        purpose = 84, // ++ debugInfo: Api should provide
        accountCoinType = 3324, // ++ debugInfo: Api should provide
        accountIndex = int.parse(json['account_index']),
        balance = json['balance'],
        curveType = 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          blockchainId == other.blockchainId &&
          currencyId == other.currencyId;

  @override
  int get hashCode => id.hashCode;
}

@DatabaseView(
    'SELECT * FROM Account INNER JOIN User ON Account.user_id = User.user_id INNER JOIN Network ON Account.blockchain_id = Network.blockchain_id INNER JOIN Currency ON Account.currency_id = Currency.currency_id',
    viewName: 'JoinAccount')
class JoinAccount {
  final String id;

  @ColumnInfo(name: 'share_account_id')
  final String shareAccountId;

  @ColumnInfo(name: 'user_id')
  final String userId;

  @ColumnInfo(name: 'blockchain_id')
  final String blockchainId;

  @ColumnInfo(name: 'currency_id')
  final String currencyId;

  final int purpose;

  @ColumnInfo(name: 'account_coin_type')
  final int accountCoinType;

  @ColumnInfo(name: 'account_index')
  final int accountIndex;

  @ColumnInfo(name: 'curve_type')
  final int curveType;

  final String balance;

  final String? contract;

  @ColumnInfo(name: 'number_of_used_external_key')
  final int? numberOfUsedExternalKey;

  @ColumnInfo(name: 'number_of_used_internal_key')
  final int? numberOfUsedInternalKey;

  @ColumnInfo(name: 'last_sync_time')
  final int? lastSyncTime;

  //user
  final String keystore;

  @ColumnInfo(name: 'third_party_id') // apple/google Id
  final String thirdPartyId;

  @ColumnInfo(name: 'install_id')
  final String installId;

  final int timestamp;
  //user

  // network
  final String network;

  @ColumnInfo(name: 'blockchain_coin_type')
  final int blockchainCoinType;

  @ColumnInfo(name: 'chain_id')
  final int chainId;
  // network

  // currency
  final String name;

  final String symbol;

  final String type;

  final bool publish;

  final int decimals;

  @ColumnInfo(name: 'exchange_rate')
  final String? exchangeRate;

  final String image;

  JoinAccount({
    required this.id,
    required this.shareAccountId,
    required this.userId,
    required this.blockchainId,
    required this.currencyId,
    required this.purpose,
    required this.accountCoinType,
    required this.accountIndex,
    required this.curveType,
    required this.balance,
    required this.numberOfUsedExternalKey,
    required this.numberOfUsedInternalKey,
    required this.lastSyncTime,
    required this.keystore,
    required this.thirdPartyId,
    required this.installId,
    required this.timestamp,
    required this.network,
    required this.blockchainCoinType,
    required this.chainId,
    required this.name,
    required this.symbol,
    required this.type,
    required this.publish,
    required this.contract,
    required this.decimals,
    required this.exchangeRate,
    required this.image,
  });

  // currency
}
