import 'package:flutter/material.dart';

import '../theme.dart';
import './restore_wallet.screen.dart';
import '../widgets/forms/create_wallet_form.dart';
import '../widgets/buttons/primary_button.dart';
import '../helpers/i18n.dart';

class WelcomeScreen extends StatelessWidget {
  static const routeName = '/landing';

  final t = I18n.t;

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
              t('create_wallet'),
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
                showModalBottomSheet(
                  // isScrollControlled: true,
                  shape: bottomSheetShape,
                  context: context,
                  builder: (context) => Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 22.0, horizontal: 16.0),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 50.0),
                          Text(
                            '選擇匯入方式',
                            style: Theme.of(context).textTheme.headline1,
                          ),
                          SizedBox(height: 84.0),
                          RestoreNav(),
                        ],
                      ),
                    ),
                  ),
                );
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

class RestoreNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(RestoreWalletScreen.routeName);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 50.0),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ImageIcon(
              AssetImage('assets/images/icons/ic_import_wallet.png'),
              color: Colors.black,
              size: 36.0,
            ),
            SizedBox(width: 20.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '匯入 PaperWallet',
                  style: Theme.of(context).textTheme.headline1,
                ),
                Text(
                  '存儲私鑰的一種加密格式',
                  style: Theme.of(context).textTheme.subtitle2,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
