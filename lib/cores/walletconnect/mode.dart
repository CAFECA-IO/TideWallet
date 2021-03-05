class ConnectionEl {
  final String topic;
  final int version;
  final String bridge;
  final String key;

  ConnectionEl({this.topic, this.version, this.bridge, this.key});
}

class ClientMeta {}

class Session {}

class Request {
  final int id;
  final String method;
  final String jsonrpc;
  final List<dynamic> params;

  Request({this.id, this.method, this.jsonrpc, this.params})
      : assert(method != null);

  Request.fromJson(Map json)
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
