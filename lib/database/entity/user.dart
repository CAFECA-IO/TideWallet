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

  @ColumnInfo(name: 'backup_status', nullable: false)
  final bool backupStatus;

  UserEntity(
    this.userId,
    this.keystore,
    this.thirdPartyId,
    this.installId,
    this.timestamp,
    this.backupStatus,
  );

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
    String userId,
    String keystore,
    String thirdPartyId,
    String installId,
    int timestamp,
    bool backupStatus,
  }) {
    return UserEntity(
      userId ?? this.userId,
      keystore ?? this.keystore,
      thirdPartyId ?? this.thirdPartyId,
      installId ?? this.installId,
      timestamp ?? this.timestamp,
      backupStatus ?? this.backupStatus,
    );
  }
}
