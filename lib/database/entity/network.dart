import 'package:floor/floor.dart';

@Entity(tableName: 'Network')
class NetworkEntity {
  @primaryKey
  @ColumnInfo(name: 'network_id')
  final String networkId;

  @ColumnInfo(nullable: false)
  final String network;

  @ColumnInfo(name: 'coin_type')
  final int coinType;

  final int type;

  @ColumnInfo(name: 'chain_id')
  final int chainId;

  NetworkEntity({
    this.networkId,
    this.network,
    this.coinType,
    this.type,
    this.chainId
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkEntity &&
          runtimeType == other.runtimeType &&
          networkId == other.networkId &&
          network == other.network &&
          type == other.type;

  @override
  int get hashCode => networkId.hashCode ^ network.hashCode ^ type.hashCode;

  NetworkEntity.fromJson(Map json)
      : this.networkId = json['blockchain_id'],
        this.network = json['name'],
        this.coinType = json['coin_type'],
        this.chainId = json['network_id'],
        this.type = json['publish'] ? 1 : 0;
}
