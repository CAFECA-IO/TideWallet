import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'package:socket_io_client/socket_io_client.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// import 'package:socket_io_client/socket_io_client.dart' as IO;

enum T_EVT { MESSAGE, OPEN, CLOSE, ERROR }

class TransportEvent {
  final T_EVT evt;
  final String value;

  TransportEvent(this.evt, this.value);
}

class Transport {
  // IO.Socket _socket;
  IOWebSocketChannel _channel;
  String _url;
  final List queus = [];
  StreamController<TransportEvent> _controller;

  Transport({String url}) {
    this._url = url;
    this._controller = StreamController<TransportEvent>();
    this._createSocket();
  }

  send(message, topic, silent) {
    this._socketSend({
      'topic': topic,
      'type': "pub",
      'payload': message,
      'silent': true,
    });
  }

  subscribe(topic) {
    this._socketSend({
      'topic': topic,
      'type': "sub",
      'payload': "",
      'silent': true,
    });
  }

  close() {
    this._socketClose();
    this._controller.close();
  }

  _createSocket() {
    // this._socket = IO.io(this._url, OptionBuilder()
    //   .setTransports(['websocket']) // for Flutter or Dart VM
    //   .build());

    // this._socket.onConnect((data) {
    //   print(data);

    //   this._controller.add(TransportEvent(T_EVT.OPEN, null));
    // });

    // this._socket.onclose((reason) {
    //   this._controller.add(TransportEvent(T_EVT.CLOSE, reason));
    // });

    this._channel = IOWebSocketChannel.connect(this._url);

    this._channel.stream.listen((data) {
      this._socketReceive(data.toString());
    });
  }

  _socketSend(Map socketMessage) {
    if (this._channel != null && this._channel.closeCode == null) {
      final msg = json.encode(socketMessage);
      print('Send: $msg');
      this._channel.sink.add(msg);
    }
  }

  _socketReceive(String message) {
    try {
      final result = json.decode(message);
      this._controller.add(TransportEvent(T_EVT.MESSAGE, message));

      this._socketSend({
        'topic': result['topic'],
        'type': "ack",
        'payload': "",
        'silent': true,
      });
    } catch (e) {
      print(e);
    }
  }

  _socketClose() {
    // this._socket.dispose();
    this._channel.sink.close();
  }

  Stream<TransportEvent> get events => this._controller.stream;
}
