import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/forms/create_wallet_form.dart';
import '../widgets/buttons/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  static const routeName = '/landing';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/welcome_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.fromLTRB(52.0, 100.0, 52.0, 40.0),
        height: double.infinity,
        child: Column(
          children: [
            Image.asset(
              'assets/images/logo_type.png',
              width: 107.0,
            ),
            Spacer(),
            PrimaryButton(
              'Create Wallet',
              () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  shape: bottomSheetShape,
                  context: context,
                  builder: (context) => Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 22.0, horizontal: 16.0),
                    child: CreateWalletForm(),
                  ),
                );
              },
              iconImg: AssetImage('assets/images/icons/ic_property_normal.png'),
            ),
            SizedBox(height: 16.0),
            PrimaryButton(
              'Restore Wallet',
              () {
               
              },
              backgroundColor: Colors.transparent.withOpacity(0.2),
              borderColor: Colors.transparent,
              iconImg: AssetImage('assets/images/icons/ic_import_wallet.png'),
            )
          ],
        ),
      ),
    );
  }
}
