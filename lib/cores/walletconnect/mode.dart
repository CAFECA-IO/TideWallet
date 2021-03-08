part of 'core.dart';

class ConnectionEl {
  final String topic;
  final int version;
  final String bridge;
  final String key;
  final WCSession session;

  ConnectionEl({this.topic, this.version, this.bridge, this.key, this.session});
}

class PeerMeta {}

class WCSession {
  bool connected;
  List<String> accounts;
  int chainId;
  String bridge;
  String key;
  String clientId;
  PeerMeta clientMeta;
  String peerId;
  PeerMeta peerMeta;
  int handshakeId;
  String handshakeTopic;
  int networkId;

  WCSession({
    this.connected,
    this.accounts,
    this.chainId,
    this.bridge,
    this.key,
    this.clientId,
    this.clientMeta,
    this.peerId,
    this.peerMeta,
    this.handshakeId,
    this.handshakeTopic,
    this.networkId
  });
}

class WCRequest {
  final int id;
  final String method;
  final String jsonrpc;
  final List<dynamic> params;

  WCRequest({this.id, this.method, this.jsonrpc, this.params})
      : assert(method != null);

  WCRequest.fromJson(Map json)
      : this.id = json['id'],
        this.method = json['method'],
        this.jsonrpc = json['jsonrpc'],
        this.params = json['params'];
}

class Response {
  final String topic;
  final String type;
  final String payload;
  final bool silent;

  Response({this.topic, this.type, this.payload, this.silent});

  Response.fromJson(Map json)
      : this.topic = json['topic'],
        this.type = json['type'],
        this.payload = json['payload'],
        this.silent = json['silent'];
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
