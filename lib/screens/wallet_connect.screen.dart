import 'package:flutter/material.dart';

import '../widgets/appBar.dart';
import '../widgets/qrcode_view.dart';

class WalletConnectScreen extends StatelessWidget {
  static const routeName = '/wallet-connect';

  _scanResult() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GeneralAppbar(
        routeName: routeName,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          QRCodeView(
            scanCallback: this._scanResult,
          ),
        ],
      ),
    );
  }
}
