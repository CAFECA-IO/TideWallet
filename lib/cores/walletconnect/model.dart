part of 'core.dart';

class ConnectionEl {
  final String topic;
  final int version;
  final String bridge;
  final String key;

  ConnectionEl(
      {required this.topic,
      required this.version,
      required this.bridge,
      required this.key});
}

class PeerMeta {
  final String name;
  final String description;
  final List icons;
  final String url;

  PeerMeta({
    required this.name,
    required this.description,
    required this.icons,
    required this.url,
  });

  PeerMeta.fromJson(Map json)
      : this.name = json['name'] ?? '',
        this.description = json['description'] ?? '',
        this.icons = json['icons'] ?? [],
        this.url = json['url'] ?? '';
}

class ConnectorOpts {
  final WCSession session;
  final PeerMeta? clientMeta;

  ConnectorOpts({
    required this.session,
    this.clientMeta,
  });
}

class WCSession {
  bool? connected;
  List<String>? accounts;
  int? chainId;
  String bridge;
  String key;
  String? clientId;
  PeerMeta? clientMeta;
  String peerId;
  PeerMeta? peerMeta;
  int? handshakeId;
  String? handshakeTopic;
  int? networkId;

  WCSession({
    this.connected,
    this.accounts,
    this.chainId,
    required this.bridge,
    required this.key,
    this.clientId,
    this.clientMeta,
    required this.peerId,
    this.peerMeta,
    this.handshakeId,
    this.handshakeTopic,
    this.networkId,
  });
}

class WCRequest {
  final int? id;
  final String method;
  final String? jsonrpc;
  final List<dynamic>? params;

  WCRequest({this.id, required this.method, this.jsonrpc, this.params});

  WCRequest.fromJson(Map json)
      : this.id = json['id'],
        this.method = json['method'],
        this.jsonrpc = json['jsonrpc'],
        this.params = json['params'];

  WCRequest copyWith({
    int? id,
    String? method,
    String? jsonrpc,
    List<dynamic>? params,
  }) {
    return WCRequest(
      id: id ?? this.id,
      method: method ?? this.method,
      jsonrpc: jsonrpc ?? this.jsonrpc,
      params: params ?? this.params,
    );
  }
}

class WCApprove {
  final String? result;
  final String? jsonrpc;
  final int? id;

  WCApprove({
    this.id,
    this.jsonrpc,
    this.result,
  });

  WCApprove.fromRequest(WCRequest req, {String? result})
      : this.id = req.id,
        this.jsonrpc = req.jsonrpc,
        this.result = result;

  toString() =>
      '{"id":${this.id},"jsonrpc":"${this.jsonrpc}","result":"${this.result}"}';
}

class WCReject {
  final int? id;
  final String? jsonrpc;
  final String? message;
  final int code;

  WCReject.fromRequest(WCRequest req, {String? message})
      : this.id = req.id,
        this.jsonrpc = req.jsonrpc,
        this.code = -32000,
        this.message = message ?? 'User Cancel';

  toString() =>
      '{"error":{"code":${this.code},"message":"${this.message}"},"id":${this.id},"jsonrpc":"${this.jsonrpc}"}';
}

class WCMessage {
  final String? topic;
  final String? type;
  final String payload;
  final bool? silent;

  WCMessage({this.topic, this.type, required this.payload, this.silent});

  WCMessage.fromJson(Map json)
      : this.topic = json['topic'],
        this.type = json['type'],
        this.payload = json['payload'],
        this.silent = json['silent'];

  String toString() =>
      '{topic: $topic, type: $type, payload: $payload, silent: $silent }';
}

class WCPayload {
  final String data;
  final String hmac;
  final String iv;

  WCPayload.fromJson(Map json)
      : this.data = json['data'],
        this.hmac = json['hmac'],
        this.iv = json['iv'];
}
