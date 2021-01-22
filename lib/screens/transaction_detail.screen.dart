import 'package:flutter/material.dart';
import 'package:tidewallet3/helpers/formatter.dart';
import 'package:tidewallet3/theme.dart';

import '../models/transaction.model.dart';
import '../helpers/i18n.dart';
import '../widgets/appBar.dart';
import '../widgets/dash_line_divider.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionDirection direction;
  final String address;
  final DateTime dateTime;
  final String amount;
  final String symbol;
  final int confirmations;
  final TransactionStatus status;

  static const routeName = '/transaction-detail';

  const TransactionDetailScreen(
      {Key key,
      this.direction,
      this.address,
      this.dateTime,
      this.amount,
      this.symbol,
      this.confirmations,
      this.status})
      : super(key: key);

  final t = I18n.t;
  @override
  Widget build(BuildContext context) {
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
                  '${direction == TransactionDirection.sent ? "-" : "+"} $amount',
                  style: Theme.of(context).textTheme.headline1.copyWith(
                      color: status != TransactionStatus.success
                          ? MyColors.secondary_03
                          : direction.color),
                ),
                SizedBox(
                  width: 8,
                ),
                Text('btc')
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
                      '${t(status.title)} ($confirmations ${t('confirmation')})',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .copyWith(color: status.color),
                    ),
                    SizedBox(width: 8),
                    ImageIcon(
                      AssetImage(status.iconPath),
                      size: 20.0,
                      color: status.color,
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
                  '(${Formatter.dateTime(dateTime)})',
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
                  address,
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
                  '${Formatter.formaDecimal('0.00035006946653')} btc',
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
                    child: Image.asset('assets/images/ic_btc_web.png'),
                    width: 24,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
