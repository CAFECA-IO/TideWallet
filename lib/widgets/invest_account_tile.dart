import 'package:flutter/material.dart';

import '../models/investment.model.dart';

class InvestAccountTile extends StatelessWidget {
  final String name;
  final InvestAccount account;
  final Function onClick;

  InvestAccountTile(this.name, this.account, this.onClick);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
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
                    account.rate.toString() + '%',
                    style: Theme.of(context).textTheme.headline3.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  Text('Annuaized',
                      style: Theme.of(context).textTheme.subtitle2)
                ],
              ),
            ),
            SizedBox(width: 10.0),
            Column(
              children: <Widget>[
                Text(account.name),
                SizedBox(height: 6.0),
                Text(name, style: Theme.of(context).textTheme.subtitle2),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            )
          ],
        ),
      ),
    );
  }
}
