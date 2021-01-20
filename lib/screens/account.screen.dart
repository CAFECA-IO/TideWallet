import 'package:flutter/material.dart';
import 'package:tidewallet3/constants/account_config.dart';
import 'package:tidewallet3/models/account.model.dart';
import 'package:tidewallet3/widgets/account_item.dart';

class AccountScreen extends StatelessWidget {
  static const routeName = '/account';

  List<Widget> _accounts() {
    List<Account> template = [];
    // String symbol;
    // for (var value in ACCOUNT.values) {
    //   print(value);

    //   switch (value) {
    //     case ACCOUNT.BTC:
    //       symbol = 'BTC';

    //       break;

    //     default:

    //   }
    // }

    return template.map((Account acc) => AccountItem(acc)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: double.infinity,
        height: 200.0,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor
            ],
          ),
        ),
        child: Column(children: [Text('≈ ')]),
      ),
      Expanded(
        child: ListView(children: _accounts()),
      )
    ]);
  }
}
