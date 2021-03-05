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

  Connector() {
    this._eventManager = EventManager();
    this._transport = Transport();

    this._initTransport();
  }

  onEvt(String evt, Function callback) {
    final event = Event(evt, callback);

    this._eventManager.subscribe(event);
  }

  connect() {
    if (this.connected) {

    }

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

  _formatRequest(Map req) {
   
  }

  _formatResponse() {

  }
  

  verifyHMAC() {}

  parseUri(String uri) {}

  
}