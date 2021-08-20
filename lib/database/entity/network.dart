import 'package:floor/floor.dart';

@Entity(tableName: 'Network')
class NetworkEntity {
  @primaryKey
  @ColumnInfo(name: 'blockchain_id')
  final String blockchainId;

  final String network;

  @ColumnInfo(name: 'blockchain_coin_type')
  final int blockchainCoinType;

  @ColumnInfo(name: 'chain_publish')
  final bool chainPublish;

  @ColumnInfo(name: 'chain_id')
  final int chainId;

  NetworkEntity(
      {required this.blockchainId,
      required this.network,
      required this.blockchainCoinType,
      required this.chainPublish,
      required this.chainId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkEntity &&
          runtimeType == other.runtimeType &&
          blockchainId == other.blockchainId &&
          network == other.network &&
          chainPublish == other.chainPublish;

  @override
  int get hashCode =>
      blockchainId.hashCode ^ network.hashCode ^ chainPublish.hashCode;

  NetworkEntity.fromJson(Map json)
      : this.blockchainId = json['blockchain_id'],
        this.network = json['name'],
        this.blockchainCoinType = json['coin_type'],
        this.chainId = json[
            'network_id'], // ++ backedn api 2021/08/12 => TODO: Change 'network_id' to 'chain_id'
        this.chainPublish = json['publish'];
}
