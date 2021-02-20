import 'package:floor/floor.dart';

@Entity(tableName: 'User')
class UserEntity {
  @primaryKey
  @ColumnInfo(name: 'user_id')
  final String userId;

  final String keystore;

  @ColumnInfo(name: 'password_hash')
  final String passwordHash;

  @ColumnInfo(name: 'password_salt')
  final String passwordSalt;

  @ColumnInfo(name: 'backup_status', nullable: false)
  final bool backupStatus;

  UserEntity(
    this.userId,
    this.keystore,
    this.passwordHash,
    this.passwordSalt,
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
    String passwordHash,
    String passwordSalt,
    bool backupStatus,
  }) {
    return UserEntity(
      userId ?? this.userId,
      keystore ?? this.keystore,
      passwordHash ?? this.passwordHash,
      passwordSalt ?? this.passwordSalt,
      backupStatus ?? this.backupStatus,
    );
  }
}
