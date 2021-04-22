import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FCM {
  static FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  static GlobalKey<NavigatorState> _navigator;

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

  static configure(GlobalKey<NavigatorState> nav) {
    FCM._navigator = nav;
    print('Start FCM!!!');

    FCM._firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on Message: ${message}');
        FCM.handleNotification(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on Launch: $message');
        FCM.handleNotification(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print('on Resume: $message');
        FCM.handleNotification(message);
      },
      onBackgroundMessage:
          Platform.isIOS ? null : FCM.myBackgroundMessageHandler,
    );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
  }

  static Future<String> getToken() {
    return FCM._firebaseMessaging.getToken();
  }

  static handleNotification(Map message) {
    Map data = Platform.isIOS ? message : message['data'];
    print('Here:: ${data['type']}, origin: $data');

   
  }
}