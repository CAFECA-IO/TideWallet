import 'package:flutter/material.dart';

import '../helpers/formatter.dart';
import '../models/account.model.dart';
import '../theme.dart';
import '../models/transaction.model.dart';
import '../helpers/i18n.dart';
import '../widgets/appBar.dart';
import '../widgets/dash_line_divider.dart';
import 'package:url_launcher/url_launcher.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Currency currency;
  final Transaction transaction;

  static const routeName = '/transaction-detail';

  const TransactionDetailScreen({Key key, this.currency, this.transaction})
      : super(key: key);

  final t = I18n.t;
  @override
  Widget build(BuildContext context) {
    print(transaction.status);
    print(transaction.amount);
    print(transaction.confirmations);
    return Scaffold(
      appBar: GeneralAppbar(
        title: t('transaction_detail'),
        routeName: TransactionDetailScreen.routeName,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        margin: EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${transaction.direction == TransactionDirection.sent ? "-" : "+"} ${transaction.amount}',
                  style: Theme.of(context).textTheme.headline1.copyWith(
                      color: transaction.status != TransactionStatus.success
                          ? MyColors.secondary_03
                          : transaction.direction.color,
                      fontSize: 32),
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  'btc',
                  style: Theme.of(context).textTheme.headline1.copyWith(
                        color: transaction.status != TransactionStatus.success
                            ? MyColors.secondary_03
                            : transaction.direction.color,
                      ),
                )
              ],
            ),
            SizedBox(height: 24),
            DashLineDivider(
              color: Theme.of(context).dividerColor,
            ),
            SizedBox(height: 16),
            Align(
              child: Text(
                t('status'),
                style: Theme.of(context).textTheme.caption,
              ),
              alignment: Alignment.centerLeft,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Align(
                child: Row(
                  children: [
                    Text(
                      '${t(transaction.status.title)} (${transaction.confirmations} ${t('confirmation')})',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .copyWith(color: transaction.status.color),
                    ),
                    SizedBox(width: 8),
                    ImageIcon(
                      AssetImage(transaction.status.iconPath),
                      size: 20.0,
                      color: transaction.status.color,
                    ),
                  ],
                ),
                alignment: Alignment.centerLeft,
              ),
            ),
            SizedBox(height: 24),
            Align(
              child: Text(
                t('time'),
                style: Theme.of(context).textTheme.caption,
              ),
              alignment: Alignment.centerLeft,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Align(
                child: Text(
                  '(${Formatter.dateTime(transaction.timestamp)})',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                alignment: Alignment.centerLeft,
              ),
            ),
            SizedBox(height: 24),
            Align(
              child: Text(
                t('transfer_to'),
                style: Theme.of(context).textTheme.caption,
              ),
              alignment: Alignment.centerLeft,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Align(
                child: Text(
                  transaction.address,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                alignment: Alignment.centerLeft,
              ),
            ),
            SizedBox(height: 24),
            Align(
              child: Text(
                t('transaction_fee'),
                style: Theme.of(context).textTheme.caption,
              ),
              alignment: Alignment.centerLeft,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Align(
                child: Text(
                  '${Formatter.formaDecimal(transaction.fee)} btc',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                alignment: Alignment.centerLeft,
              ),
            ),
            SizedBox(height: 24),
            Align(
              child: Text(
                t('transaction_id'),
                style: Theme.of(context).textTheme.caption,
              ),
              alignment: Alignment.centerLeft,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    // child: Image.asset('assets/images/ic_btc_web.png'),
                    child: Image.asset(currency.imgPath),
                    width: 24,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  GestureDetector(
                    onTap: _launchURL,
                    child: Text(
                      Formatter.formateAdddress(transaction.txId),
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                          color: Theme.of(context).primaryColor,
                          decoration: TextDecoration.underline),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

_launchURL() async {
  const url = 'https://flutter.dev';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
