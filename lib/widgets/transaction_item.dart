import 'package:flutter/material.dart';

import '../theme.dart';
import '../helpers/i18n.dart';
import '../helpers/formatter.dart';
import '../models/transaction.model.dart';
import '../models/account.model.dart';
import '../screens/transaction_detail.screen.dart';

// class TransactionItem extends StatefulWidget {
class TransactionItem extends StatelessWidget {
  final Account account;
  final Transaction transaction;

  const TransactionItem(
      {Key? key, required this.account, required this.transaction})
      : super(key: key);

  final t = I18n.t;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(TransactionDetailScreen.routeName,
            arguments: {"account": account, "transaction": transaction});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
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
                    transaction.status == TransactionStatus.fail
                        ? SizedBox(
                            width: 28,
                          )
                        : Row(
                            children: [
                              ImageIcon(
                                AssetImage(transaction.direction.iconPath),
                                size: 20.0,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                            ],
                          ),
                    Text(
                      t(transaction.direction.title),
                      style: transaction.status == TransactionStatus.fail
                          ? Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(color: Theme.of(context).cursorColor)
                          : Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                ),
                Text(
                  '${transaction.direction == TransactionDirection.received ? "+" : "-"} ${transaction.amount} ${account.symbol.toUpperCase()}',
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: transaction.status == TransactionStatus.fail
                          ? Theme.of(context).cursorColor
                          : transaction.direction.color),
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
                      t(transaction.direction.subtitle) +
                          ": ${Formatter.formatAdddress(transaction.address)}",
                      style: transaction.status == TransactionStatus.fail
                          ? Theme.of(context)
                              .textTheme
                              .subtitle2!
                              .copyWith(color: Theme.of(context).cursorColor)
                          : Theme.of(context).textTheme.subtitle2,
                    ),
                  ],
                ),
                Text(
                  Formatter.dateTime(transaction.dateTime!),
                  style: transaction.status == TransactionStatus.fail
                      ? Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(color: Theme.of(context).cursorColor)
                      : Theme.of(context).textTheme.subtitle2,
                )
              ],
            ),
            transaction.confirmations! > 6 ||
                    transaction.status == TransactionStatus.fail
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
                          value: transaction.confirmations! / 6,
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
