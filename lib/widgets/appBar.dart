import 'package:flutter/material.dart';

import '../theme.dart';
import '../screens/account.screen.dart';
import '../screens/restore_wallet.screen.dart';
import '../screens/scan_wallet.screen.dart';
import '../screens/scan_address.screen.dart';
import '../screens/wallet_connect.screen.dart';
import '../screens/transaction_list.screen.dart';
import '../screens/transaction_preview.screen.dart';
import '../screens/create_transaction.screen.dart';
import '../screens/transaction_detail.screen.dart';
import '../screens/currency.screen.dart';
import '../screens/settings.screen.dart';
import '../screens/add_currency.screen.dart';
import '../screens/receive.screen.dart';
import '../screens/setting_fiat.screen.dart';

class GeneralAppbar extends StatelessWidget with PreferredSizeWidget {
  final String title;
  final String routeName;
  final Function leadingFunc;
  final Map actions;

  // For Appbar actions
  final bool disable;

  GeneralAppbar(
      {this.title: '',
      this.routeName,
      this.leadingFunc,
      this.actions,
      this.disable: false});

  @override
  Widget build(BuildContext context) {
    Widget genLeading(String routeName) {
      Widget leading = SizedBox();
      switch (routeName) {
        case WalletConnectScreen.routeName:
        case CreateTransactionScreen.routeName:
        case TransactionPreviewScreen.routeName:
        case ScanWalletScreen.routeName:
        case ScanAddressScreen.routeName:
        case RestoreWalletScreen.routeName:
        case TransactionListScreen.routeName:
        case TransactionDetailScreen.routeName:
        case CurrencyScreen.routeName:
        case AddCurrencyScreen.routeName:
        case ReceiveScreen.routeName:
        case SettingFiatScreen.routeName:
          leading = GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: ImageIcon(
              AssetImage('assets/images/icons/btn_back_black_normal.png'),
              color: Colors.white,
              size: 40.0,
            ),
            onTap: leadingFunc ??
                () {
                  Navigator.of(context).pop();
                },
          );
          break;
        // case AccountScreen.routeName:
        // case SwapScreen.routeName:
        // case InvestmentScreen.routeName:
        //   leading = GestureDetector(
        //     behavior: HitTestBehavior.translucent,
        //     child: Icon(
        //       Icons.insert_chart,
        //       color: Theme.of(context).primaryColor,
        //       size: 28,
        //     ),
        //     onTap: leadingFunc ??
        //         () {
        //           // TODO
        //           // Navigator.of(context).pushNamed(CreateWalletScreen.routeName);
        //         },
        //   );
        //   break;

        default:
      }

      return leading;
    }

    Widget actionItem(Widget content, Function func) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: Container(
          padding: const EdgeInsets.only(right: 16.0),
          child: Center(child: content),
        ),
        onTap: func,
      );
    }

    List<Widget> genActions(String routeName) {
      List<Widget> _actions = [];

      switch (routeName) {
        case AccountScreen.routeName:
          _actions = [
            actionItem(
                ImageIcon(
                  AssetImage('assets/images/icons/ic_notification_tip.png'),
                  size: 44.0,
                  color: Colors.white,
                ),
                () {})
          ];
          break;
        // case TransferScreen.routeName:
        // case ReceiveScreen.routeName:
        // case BuyCryptoScreen.routeName:
        // case InfoScreen.routeName:
        //   _actions = [
        //     actionItem(
        //         Icon(
        //           Icons.close,
        //           color: MyColors.ui_01,
        //           size: 28,
        //         ), () {
        //       Navigator.of(context).pop();
        //     })
        //   ];
        //   break;
        // case VerifyMnemonicScreen.routeName:
        //   _actions = actions.entries.map((MapEntry entry) {
        //     return actionItem(
        //         Text(
        //           entry.key,
        //           style: Theme.of(context).textTheme.bodyText1,
        //         ),
        //         entry.value);
        //   }).toList();
        //   break;
        // case RestoreWalletScreen.routeName:
        //   _actions = actions.entries.map((MapEntry entry) {
        //     return actionItem(
        //         Icon(
        //           Icons.check,
        //           color: disable
        //               ? MyColors.text_01.withOpacity(0.5)
        //               : MyColors.text_01,
        //           size: 28,
        //         ),
        //         entry.value);
        //   }).toList();

        //   break;
        // case AccountScreen.routeName:
        // case SwapScreen.routeName:
        // case InvestmentScreen.routeName:
        //   _actions = [
        //     actionItem(
        //       Icon(
        //         Icons.developer_board,
        //         color: Theme.of(context).primaryColor,
        //         size: 28,
        //       ),
        //       () {
        //         // TODO:
        //         // Navigator.of(context)
        //         //     .pushReplacementNamed(CreateWalletScreen.routeName);
        //       },
        //     )
        //   ];
        //   break;
        // case CurrencyDetailScreen.routeName:
        //   _actions = actions.entries.map((MapEntry entry) {
        //     return actionItem(
        //         Icon(
        //           entry.key == 'hide' ? Icons.visibility_off : Icons.info,
        //           color: MyColors.text_01,
        //           size: 28,
        //         ),
        //         entry.value);
        //   }).toList();
        //   break;
        default:
      }

      return _actions;
    }

    bool showBackground() {
      if (routeName == ScanWalletScreen.routeName) return false;
      if (routeName == TransactionListScreen.routeName) return false;
      if (routeName == AccountScreen.routeName) return false;
      if (routeName == CurrencyScreen.routeName) return false;
      if (routeName == SettingsScreen.routeName) return false;
      return true;
    }

    return AppBar(
      centerTitle: true,
      elevation: 0,
      title: Text(
        title,
        style: Theme.of(context).textTheme.headline5,
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.transparent,
      flexibleSpace: showBackground()
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[
                    Theme.of(context).primaryColor,
                    Theme.of(context).accentColor
                  ],
                ),
              ),
            )
          : null,
      leading: genLeading(routeName),
      actions: genActions(routeName),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
