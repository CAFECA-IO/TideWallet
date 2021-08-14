import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../models/account.model.dart';
import '../helpers/formatter.dart';

class AccountItem extends StatelessWidget {
  final Account _account;
  final Function _onClick;
  final Fiat fiat;
  Color? _testnetColor;
  AccountItem(this._account, this._onClick, {required this.fiat}) {
    if (!_account.publish) {
      _testnetColor = Colors.black26;
    }
  }

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
            Image.network(
              _account.imgPath,
              width: 26.0,
              height: 26.0,
            ),
            SizedBox(height: 4.0),
            Text(
              _account.symbol,
              style: TextStyle(
                  color: !_account.publish
                      ? _testnetColor ?? Colors.black
                      : Colors.black),
            ),
            Text(Formatter.formatDecimal(_account.balance),
                style: TextStyle(
                    color: !_account.publish
                        ? _testnetColor ?? Colors.black
                        : Colors.black)),
            Text(
                '≈ ${Formatter.formatDecimal((Decimal.tryParse(_account.inFiat)! / fiat.exchangeRate).toString(), decimalLength: 2)} ${fiat.name}',
                style: Theme.of(context).textTheme.subtitle2!.copyWith(
                    color: !_account.publish
                        ? _testnetColor ?? Colors.black
                        : Colors.black))
          ],
        ),
      ),
    );
  }
}
