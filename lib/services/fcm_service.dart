import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:tidewallet3/models/account.model.dart';

import 'account_service.dart';
import 'bitcoin_service.dart';
import '../cores/account.dart';
import '../models/fcm.modal.dart';
import '../screens/transaction_list.screen.dart';

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
        this.handleNotification(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        this.handleNotification(message);
      },
      onResume: (Map<String, dynamic> message) async {
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

    FCMMsg msg = FCMMsg.fromOriginData(data);
    if (AccountCore().isInit) {
      this.applyEvent(msg);
    } else {
      _subscription?.cancel();
      _subscription = _controller.stream.listen((event) {
        if (event == FCM_LOCAL_EVENT.UNLOCK_APP) {
         
          this.applyEvent(msg, navigate: true);
        }
      });
    }
  }

  applyEvent(FCMMsg msg, {bool navigate = false}) async {
    if (msg.event == FCM_EVENT.TRANSACTION_NEW) {
      AccountService svc = AccountCore().getService(msg.accountId);
      await svc.updateTransaction(msg.currencyId, msg.payload);
      await svc.updateCurrency(msg.currencyId, msg.payload);
      // await svc.updateCurrency(msg.currencyId, {'balance': '100'});

      if (navigate) {
        Currency account = AccountCore()
            .currencies[msg.accountId]
            .firstWhere((currency) => currency.currencyId == msg.currencyId);

        this._navigator.currentState.pushNamed(TransactionListScreen.routeName,
            arguments: {"account": account});
      }
    }

    if (msg.event == FCM_EVENT.UTXO) {
      AccountService svc = AccountCore().getService(msg.accountId);

      if (svc is BitcoinService) {
        // svc.updateUTXO(msg.currencyId, msg.payload);
      } else {
        // TODO: For Dash Or Litcoin?

      }
    }
  }

  close() {
    this._controller.close();
  }
}
