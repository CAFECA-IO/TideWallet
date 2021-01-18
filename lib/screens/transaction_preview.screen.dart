import 'package:flutter/material.dart';

import '../widgets/appBar.dart';
import '../widgets/buttons/secondary_button.dart';

class TransactionPreviewScreen extends StatelessWidget {
  static const routeName = '/transaction-preview';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralAppbar(
        title: "Preview",
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
                    child: Text("To"),
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
                    child: Text("Amount"),
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
                    child: Text("Transaction Fee"),
                    alignment: Alignment.centerLeft,
                  ),
                  SizedBox(height: 7),
                  Align(
                    child: Text("0.000023 btc"),
                    alignment: Alignment.centerLeft,
                  ),
                  SizedBox(height: 4),
                  Align(
                    child: Text("≈ 10 USD"),
                    alignment: Alignment.centerLeft,
                  ),
                ],
              ),
            ),
            SizedBox(height: 261),
            SecondaryButton("Confirm", () {}),
          ],
        ),
      ),
    );
  }
}
