import 'transport.dart';
import 'mode.dart';
import 'event_manager.dart';
import 'error.dart';

class Connector {
  String protocol = 'wc';
  String _key;
  int version = 1;
  String _bridge = '';
  String _clientId;
  ClientMeta _clientMeta;
  bool connected = false;
  Session session;
  EventManager _eventManager;
  Transport _transport;
  String _handshakeTopic;
  int _handshakeId;

  set bridge(String value) {
    this._bridge = value;
  }

  set key(String value) {
    this._key = value;
  }

  set clientId(String value) {
    this._clientId = value;
  }

  String get bridge => this._bridge;
  String get key => this._key;
  String get clientId => this._clientId;
  ClientMeta get clientMeta => this._clientMeta;

  Connector(ConnectionEl opt) {
    this._eventManager = EventManager();

    this._bridge = opt.bridge;
    this._transport = Transport(url: this._bridge);
    this._transport.subscribe(opt.topic);

    // this._handshakeTopic = opt.topic;
    // this._key = opt.key;

    this._initTransport();
  }

  onEvt(String evt, Function callback) {
    final event = Event(evt, callback);

    this._eventManager.subscribe(event);
  }

  connect() {
    if (this.connected) {}
  }

  createSession() {
    if (this.connected) {
      throw (ERROR_SESSION.CONNECTED);
    }
  }

  _initTransport() {
    this._transport.events.listen((event) {
      switch (event.evt) {
        case T_EVT.MESSAGE:
          this._handleIncomingMessages(event.value);
          break;
        case T_EVT.OPEN:

        default:
      }
    });
  }

  _handleIncomingMessages(v) {
    print(v);
  }

  _formatRequest(Map req) {}

  _formatResponse() {}

  verifyHMAC() {}

  // TODO:
  static ConnectionEl parseUri(String uri) {
    try {
      var tmp = uri.split('bridge=');
      final b = tmp[0].replaceAll('wc:', '').split('@');
      final topic = b[0];
      final version = b[1];
      final d = tmp[1];
      tmp = d.split('&key=');
      final url = tmp[0].replaceAll('https%3A%2F%2F', 'wss://');
      final key = tmp[1];

      return ConnectionEl(
          topic: topic, version: int.tryParse(version), bridge: url, key: key);
    } catch (e) {
      return null;
    }
  }
}
