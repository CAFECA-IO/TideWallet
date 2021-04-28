import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class BuyTidePointScreen extends StatefulWidget {
  static const routeName = '/buying';
  @override
  _BuyTidePointScreenState createState() => _BuyTidePointScreenState();
}

class _BuyTidePointScreenState extends State<BuyTidePointScreen> {
  StreamSubscription<List<PurchaseDetails>> _subscription;
  @override
  void initState() {
    final Stream purchaseUpdated =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      // _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
