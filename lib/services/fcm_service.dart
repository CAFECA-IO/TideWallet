import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../cores/account.dart';

enum FCM_LOCAL_EVENT { UNLOCK_APP }

class FCM {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  static final FCM _instance = FCM._internal();
  factory FCM() => _instance;
  FCM._internal();

  GlobalKey<NavigatorState> _navigator;
  StreamController _controller = StreamController();
  StreamSubscription _subscription;

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) {
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
    }

    print('onBackgroundMessage: $message');
    // Or do other work.
  }

  configure(GlobalKey<NavigatorState> nav) {
    this._navigator = nav;

    this._firebaseMessaging.configure(
          onMessage: (Map<String, dynamic> message) async {
            print('on Message: ${message}');
            this.handleNotification(message);
          },
          onLaunch: (Map<String, dynamic> message) async {
            print('on Launch: $message');
            this.handleNotification(message);
          },
          onResume: (Map<String, dynamic> message) async {
            print('on Resume: $message');
            this.handleNotification(message);
          },
          onBackgroundMessage:
              Platform.isIOS ? null : FCM.myBackgroundMessageHandler,
        );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
  }

  Future<String> getToken() {
    return this._firebaseMessaging.getToken();
  }

  StreamController get emmiter => this._controller;

  handleNotification(Map message) {
    Map data = Platform.isIOS ? message : message['data'];
    print('Here:: ${data['type']}, origin: $data');

    if (AccountCore().isInit) {
      this.applyEvent();
    } else {
      _subscription?.cancel();
      _subscription = _controller.stream.listen((event) {
        if (event == FCM_LOCAL_EVENT.UNLOCK_APP) {
          this.applyEvent();
        }
      });
    }
  }

  applyEvent() {
    // TODO: 
    // AccountCore().currencies['2432f094-1aae-4077-8fa1-518a0f9efb24'].forEach((v) {
    //   print(v);
    // });
  }


}
