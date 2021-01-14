import 'package:flutter/material.dart';

import '../widgets/appBar.dart';

class WalletConnectScreen extends StatelessWidget {
  static const routeName = '/wallet-connect';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralAppbar(routeName: routeName,),
      body: Container(
        child: Text('Hello WalletConnect Screen'),
      ),
    );
  }
}
