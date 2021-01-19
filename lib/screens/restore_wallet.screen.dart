
import 'package:flutter/material.dart';
import 'package:tidewallet3/widgets/appBar.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import './scan_wallet.screen.dart';
import '../widgets/buttons/secondary_button.dart';

class RestoreWalletScreen extends StatefulWidget {
  static const routeName = '/restore-wallet';

  @override
  _RestoreWalletScreenState createState() => _RestoreWalletScreenState();
}

class _RestoreWalletScreenState extends State<RestoreWalletScreen> {
  @override
  Widget build(BuildContext context) {
    final _btnColor = Theme.of(context).accentColor;
    return Scaffold(
      appBar: GeneralAppbar(
        routeName: RestoreWalletScreen.routeName,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 14.0),
              decoration: BoxDecoration(
                color: Color(0xFFBEEFF0),
              ),
              child: Text(
                'Ethereum’s official wallet uses keystore format to store encrypted private key information, you can copy and paste the content into the input field, or with the help of QR code generate.',
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 36.0, vertical: 12.0),
              child: SecondaryButton(
                '掃描',
                () {
                  Navigator.of(context).pushNamed(ScanWalletScreen.routeName);
                },
                textColor: _btnColor,
                borderColor: _btnColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}

