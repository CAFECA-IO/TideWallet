import 'package:floor/floor.dart';

@Entity(tableName: 'User')
class UserEntity {
  @primaryKey
  @ColumnInfo(name: 'user_id')
  final String userId;

  final String keystore;

  @ColumnInfo(name: 'third_party_id') // apple/google Id
  final String thirdPartyId;

  @ColumnInfo(name: 'install_id')
  final String installId;

  final int timestamp;

  @ColumnInfo(name: 'last_sync_time')
  int? lastSyncTime;

  UserEntity({
    required this.userId,
    required this.keystore,
    required this.thirdPartyId,
    required this.installId,
    required this.timestamp,
    this.lastSyncTime,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          keystore == other.keystore;

  @override
  int get hashCode => userId.hashCode ^ keystore.hashCode;

  UserEntity copyWith({
    String? userId,
    String? keystore,
    String? thirdPartyId,
    String? installId,
    int? timestamp,
    int? lastSyncTime,
  }) {
    return UserEntity(
      userId: userId ?? this.userId,
      keystore: keystore ?? this.keystore,
      thirdPartyId: thirdPartyId ?? this.thirdPartyId,
      installId: installId ?? this.installId,
      timestamp: timestamp ?? this.timestamp,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}
