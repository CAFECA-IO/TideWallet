import '../mock/endpoint.dart';

import '../models/account.model.dart';

class Trader {
  Future<List<Fiat>> getFiatList() async {
    List<Map> result = await fiatList();
    return result.map((e) => Fiat.fromMap(e)).toList();
  }

  Future<Fiat> getSelectedFiat() async {
    await Future.delayed(Duration(milliseconds: 300));

    return null;
  }
}