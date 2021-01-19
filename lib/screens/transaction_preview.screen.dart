import 'package:flutter/material.dart';

import '../helpers/i18n.dart';
import '../theme.dart';
import '../widgets/appBar.dart';
import '../widgets/buttons/secondary_button.dart';

class TransactionPreviewScreen extends StatelessWidget {
  static const routeName = '/transaction-preview';
  final t = I18n.t;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralAppbar(
        title: t('preview'),
        routeName: routeName,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Container(
              // alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Column(
                children: [
                  Align(
                    child: Text(
                      t('to'),
                      style: Theme.of(context).textTheme.caption,
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                  SizedBox(height: 7),
                  Align(
                    child: Text("18e044328d1687c13300fdc28a18e044328d1687c13"),
                    alignment: Alignment.centerLeft,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Column(
                children: [
                  Align(
                    child: Text(
                      t('amount'),
                      style: Theme.of(context).textTheme.caption,
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                  SizedBox(height: 7),
                  Align(
                    child: Text("20 btc"),
                    alignment: Alignment.centerLeft,
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Column(
                children: [
                  Align(
                    child: Text(
                      t('transaction_fee'),
                      style: Theme.of(context).textTheme.caption,
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                  SizedBox(height: 7),
                  Align(
                    child: Text("0.000023 btc"),
                    alignment: Alignment.centerLeft,
                  ),
                  SizedBox(height: 4),
                  Align(
                    child: Text(
                      "≈ 10 USD",
                      style: Theme.of(context).textTheme.caption,
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                ],
              ),
            ),
            SizedBox(height: 261),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 36),
              child: SecondaryButton(
                "Confirm",
                () {},
                textColor: MyColors.primary_03,
                borderColor: MyColors.primary_03,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
