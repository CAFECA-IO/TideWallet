import 'package:flutter/material.dart';
import 'package:tidewallet3/theme.dart';

import '../helpers/i18n.dart';
import '../helpers/formatter.dart';
import '../models/transaction.model.dart';
import '../screens/transaction_detail.screen.dart';

class TransactionItem extends StatefulWidget {
  final TransactionDirection direction;
  final String address;
  final DateTime dateTime;
  final String amount;
  // final String amountInFiat;
  final String symbol;
  // final String fiat;
  final int confirmations;
  final TransactionStatus status;

  const TransactionItem(
      {Key key,
      this.direction,
      this.address,
      this.dateTime,
      this.amount,
      // this.amountInFiat,
      this.symbol,
      // this.fiat,
      this.confirmations,
      this.status})
      : super(key: key);
  @override
  _TransactionItemState createState() => _TransactionItemState();
}

class _TransactionItemState extends State<TransactionItem> {
  final t = I18n.t;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => TransactionDetailScreen(
                  direction: widget.direction,
                  address: widget.address,
                  dateTime: widget.dateTime,
                  amount: widget.amount,
                  symbol: widget.symbol,
                  confirmations: widget.confirmations,
                  status: widget.status,
                )));
      },
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ImageIcon(
                      AssetImage(widget.direction.iconPath),
                      size: 20.0,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(t(widget.direction.title)),
                  ],
                ),
                Text(
                  '${widget.direction == TransactionDirection.received ? "" : "-"} ${widget.amount} ${widget.symbol.toUpperCase()}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(color: widget.direction.color),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 28,
                    ),
                    Text(
                      widget.direction.subtitle,
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ],
                ),
                Text(Formatter.dateTime(widget.dateTime),
                    style: Theme.of(context).textTheme.subtitle2)
              ],
            ),
            widget.confirmations > 6
                ? SizedBox(
                    height: 32,
                  )
                : Column(
                    children: [
                      SizedBox(
                        height: 8,
                      ),
                      Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${t("process")}...',
                            style: Theme.of(context).textTheme.subtitle2,
                          )),
                      Container(
                        padding: EdgeInsets.only(top: 4),
                        child: LinearProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor),
                          value: widget.confirmations / 6,
                          backgroundColor: MyColors.secondary_05,
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

enum Property { iconPath, title, subtitle, color }
