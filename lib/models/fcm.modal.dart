import 'dart:convert';

import 'package:flutter/foundation.dart';

enum FCM_EVENT {
  TRANSACTION,
  TRANSACTION_NEW,
  TRANSACTION_CONFIRM,
  UTXO
}

class FCMMsg {
  final FCM_EVENT event;
  final String accountId;
  final String currencyId;
  final Map payload;

  FCMMsg({
    this.event,
    this.accountId,
    this.currencyId,
    this.payload
  });

  static FCMMsg fromOriginData(Map data) {
    final body = json.decode(data['body']);
    FCM_EVENT event = FCM_EVENT.values.firstWhere((e) => describeEnum(e) == body['eventType']);
    return FCMMsg(
      event: event,
      accountId: body['accountId'],
      currencyId: body['currencyId'],
      payload: body['data']
    );
  }
}