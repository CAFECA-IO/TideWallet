import 'package:flutter/material.dart';

import '../widgets/appBar.dart';
import '../widgets/qrcode_view.dart';

class ScanWalletScreen extends StatefulWidget {
  static const routeName = '/scan-wallet';
  @override
  _ScanWalletScreenState createState() => _ScanWalletScreenState();
}

class _ScanWalletScreenState extends State<ScanWalletScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GeneralAppbar(routeName: ScanWalletScreen.routeName, title: 'Scan your Keystore',),
      body: QRCodeView(),
    );
  }
}