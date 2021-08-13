import 'package:flutter/material.dart';

import '../models/investment.model.dart';
import '../models/account.model.dart';
import '../helpers/i18n.dart';

final t = I18n.t;

class InvestAccountTile extends StatelessWidget {
  final Account account;
  final Investment investment;
  final Function()? onClick;

  InvestAccountTile(this.account, this.investment, this.onClick);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(t(investment.investStrategy.value) +
                    "  (" +
                    t(investment.investAmplitude.value) +
                    ")"),
                SizedBox(height: 6.0),
                Text(investment.investAmount.toString() + " " + account.symbol!,
                    style: Theme.of(context).textTheme.subtitle2),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    investment.iRR.toString() + '%',
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  Text('Annuaized',
                      style: Theme.of(context).textTheme.subtitle2)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
