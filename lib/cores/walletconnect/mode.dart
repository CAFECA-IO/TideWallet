class ClientMeta {

}

class Session {

}

class Request {
  final int id;
  final String method;
  final String jsonrpc;
  final List<dynamic> params;

  Request({
    this.id,
    this.method,
    this.jsonrpc,
    this.params
  }) : assert(method != null);

  Request.fromJson(Map json) :
    assert(method != null),
    this.id = json['id'],
    this.method = json['method'],
    this.jsonrpc = json['jsonrpc'],
    this.params = json['params'];
}