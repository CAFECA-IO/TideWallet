import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as IO;

enum T_EVT {
  MESSAGE,
  OPEN,
  CLOSE,
  ERROR
}
class TransportEvent {
  final T_EVT evt;
  final String value;

  TransportEvent(this.evt, this.value);
}
class Transport {
  IO.Socket _socket;
  String _url;
  final List queus = [];
  StreamController _controller;

  Transport({
    String url
  }) {
    this._url = url;
    this._createSocket();
  }
  
  _createSocket() {
    _socket = IO.io(this._url);

    _socket.onConnect((data) {
      print(data);

      this._controller.add(TransportEvent(T_EVT.OPEN, null));
    });
  }

  Stream<TransportEvent> get events => this._controller.stream;


}
