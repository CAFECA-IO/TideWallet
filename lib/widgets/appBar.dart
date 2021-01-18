import 'package:flutter/material.dart';
import 'package:tidewallet3/screens/create_transaction.screen.dart';
import 'package:tidewallet3/screens/transaction_preview.screen.dart';

import '../theme.dart';
import '../screens/wallet_connect.screen.dart';

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
          leading = GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Icon(
              Icons.arrow_back_ios,
              color: MyColors.secondary_01,
              size: 28,
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

      // switch (routeName) {
      //   case TransferScreen.routeName:
      //   case ReceiveScreen.routeName:
      //   case BuyCryptoScreen.routeName:
      //   case InfoScreen.routeName:
      //     _actions = [
      //       actionItem(
      //           Icon(
      //             Icons.close,
      //             color: MyColors.ui_01,
      //             size: 28,
      //           ), () {
      //         Navigator.of(context).pop();
      //       })
      //     ];
      //     break;
      //   case VerifyMnemonicScreen.routeName:
      //     _actions = actions.entries.map((MapEntry entry) {
      //       return actionItem(
      //           Text(
      //             entry.key,
      //             style: Theme.of(context).textTheme.bodyText1,
      //           ),
      //           entry.value);
      //     }).toList();
      //     break;
      //   case RestoreWalletScreen.routeName:
      //     _actions = actions.entries.map((MapEntry entry) {
      //       return actionItem(
      //           Icon(
      //             Icons.check,
      //             color: disable
      //                 ? MyColors.text_01.withOpacity(0.5)
      //                 : MyColors.text_01,
      //             size: 28,
      //           ),
      //           entry.value);
      //     }).toList();

      //     break;
      //   case AccountScreen.routeName:
      //   case SwapScreen.routeName:
      //   case InvestmentScreen.routeName:
      //     _actions = [
      //       actionItem(
      //         Icon(
      //           Icons.developer_board,
      //           color: Theme.of(context).primaryColor,
      //           size: 28,
      //         ),
      //         () {
      //           // TODO:
      //           // Navigator.of(context)
      //           //     .pushReplacementNamed(CreateWalletScreen.routeName);
      //         },
      //       )
      //     ];
      //     break;
      //   case CurrencyDetailScreen.routeName:
      //     _actions = actions.entries.map((MapEntry entry) {
      //       return actionItem(
      //           Icon(
      //             entry.key == 'hide' ? Icons.visibility_off : Icons.info,
      //             color: MyColors.text_01,
      //             size: 28,
      //           ),
      //           entry.value);
      //     }).toList();
      //     break;
      //   default:
      // }

      return _actions;
    }

    return AppBar(
      centerTitle: true,
      elevation: 0,
      title: Text(
        title,
        style: Theme.of(context).textTheme.headline5,
        textAlign: TextAlign.center,
      ),
      backgroundColor: Theme.of(context).accentColor,
      leading: genLeading(routeName),
      actions: genActions(routeName),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
