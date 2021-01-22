import 'package:flutter/material.dart';

import '../models/transaction.model.dart';
import 'package:tidewallet3/models/transaction.model.dart';

import './create_transaction.screen.dart';
import '../theme.dart';
import '../widgets/appBar.dart';
import '../widgets/buttons/tertiary_button.dart';
import '../widgets/transaction_item.dart';

import '../helpers/formatter.dart';
import '../helpers/i18n.dart';

class TransactionListScreen extends StatelessWidget {
  static const routeName = '/transaction-list';
  final t = I18n.t;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: GeneralAppbar(
            title: '',
            routeName: TransactionListScreen.routeName,
          ),
          body: Container(
            child: Column(children: [
              Container(
                width: double.infinity,
                // height: 300.0,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Theme.of(context).primaryColor,
                      Theme.of(context).accentColor
                    ],
                  ),
                ),
                child: Column(children: [
                  // Spacer(),
                  SizedBox(height: 100),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: MyColors.font_01, shape: BoxShape.circle),
                    child: Image.asset(
                      'assets/images/ic_btc_web.png',
                      width: 32.0,
                      height: 32.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      'BTC',
                      style: Theme.of(context).textTheme.button,
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('${Formatter.formaDecimal('3.1203411')}',
                        style: Theme.of(context).textTheme.headline4),
                  ),
                  Text(
                    '${String.fromCharCode(0x2248)} ${Formatter.formaDecimal('800.331') + " USD"}',
                    style: Theme.of(context).textTheme.button,
                  ),
                  SizedBox(height: 24),
                ]),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        bottom:
                            BorderSide(color: Theme.of(context).dividerColor))),
                child: Row(
                  children: [
                    Expanded(
                        child: TertiaryButton(
                      t('send'),
                      () {
                        Navigator.of(context)
                            .pushNamed(CreateTransactionScreen.routeName);
                      },
                      textColor: MyColors.primary_04,
                      iconImg:
                          AssetImage('assets/images/icons/ic_send_black.png'),
                    )),
                    Expanded(
                        child: TertiaryButton(
                      t('receive'),
                      () {
                        // Navigator.of(context)
                        //     .pushNamed(ReceiveScreen.routeName);
                      },
                      textColor: MyColors.primary_03,
                      iconImg: AssetImage(
                          'assets/images/icons/ic_receive_black.png'),
                    )),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: ListView(
                      children: [
                        TransactionItem(
                          status: TransactionStatus.success,
                          symbol: "btc",
                          amount: '0.09',
                          direction: TransactionDirection.sent,
                          dateTime: DateTime.now(),
                          confirmations: 23,
                          address: 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
                        ),
                        TransactionItem(
                          status: TransactionStatus.success,
                          symbol: "btc",
                          amount: '0.55',
                          direction: TransactionDirection.received,
                          dateTime: DateTime.now(),
                          confirmations: 7,
                          address: 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
                        ),
                        TransactionItem(
                          status: TransactionStatus.pending,
                          symbol: "btc",
                          amount: '0.39',
                          direction: TransactionDirection.sent,
                          dateTime: DateTime.now(),
                          confirmations: 2,
                          address: 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
                        )
                      ],
                    ),
                  ),
                ),
                // child: ListView.builder(
                //   itemBuilder: ((context, index) {
                //     return TransactionItem(
                //       symbol: "btc",
                //       amount: '0.55',
                //       direction: TransactionDirection.sent,
                //       dateTime: DateTime.now(),
                //       confirmations: 0,
                //     );
                //   }),
                // ),
              )
            ]),
          )),
    );
  }
}
