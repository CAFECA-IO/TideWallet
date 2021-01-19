import 'package:flutter/material.dart';

import '../theme.dart';
import '../screens/scan_wallet.screen.dart';
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
        case ScanWalletScreen.routeName:
          leading = GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: ImageIcon(AssetImage('assets/images/icons/btn_back_black_normal.png'), color: Colors.white, size: 40.0,),
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
        // case TransferScreen.routeName:
        //   leading = GestureDetector(
        //       behavior: HitTestBehavior.translucent,
        //       child: Icon(
        //         Icons.format_list_bulleted,
        //         color: MyColors.ui_01,
        //         size: 28,
        //       ),
        //       onTap: leadingFunc);
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

    Color bgColor() {
      if (routeName == ScanWalletScreen.routeName) return Colors.transparent;
      return Theme.of(context).accentColor;
    }

    return AppBar(
      centerTitle: true,
      elevation: 0,
      title: Text(
        title,
        style: Theme.of(context).textTheme.headline5,
        textAlign: TextAlign.center,
      ),
      backgroundColor: bgColor(),
      leading: genLeading(routeName),
      actions: genActions(routeName),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
