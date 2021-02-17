import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../models/account.model.dart';
import '../helpers/formatter.dart';

class AccountItem extends StatelessWidget {
  final Currency _account;
  final Function _onClick;
  final Fiat fiat;
  AccountItem(this._account, this._onClick, {this.fiat});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _onClick();
      },
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              _account.imgPath,
              width: 26.0,
              height: 26.0,
            ),
            SizedBox(height: 4.0),
            Text(_account.symbol),
            Text(_account.amount),
            Text(
                fiat != null
                    ? '≈ ${Formatter.formatDecimal((Decimal.tryParse(_account.inUSD) / fiat.exchangeRate).toString(), decimalLength: 2)} ${fiat.name}'
                    : '',
                style: Theme.of(context).textTheme.subtitle2)
          ],
        ),
      ),
    );
  }
}
