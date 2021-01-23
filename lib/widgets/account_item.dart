import 'package:flutter/material.dart';
import 'package:tidewallet3/models/account.model.dart';

class AccountItem extends StatelessWidget {
  final Currency _account;
  final Function _onClick;
  AccountItem(this._account, this._onClick);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _onClick();
      },
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(
            _account.imgPath,
            width: 26.0,
            height: 26.0,
          ),
          SizedBox(height: 4.0),
          Text(_account.symbol),
          Text(_account.amount),
          Text('≈ ${_account.fiat} USD',
              style: Theme.of(context).textTheme.subtitle2)
        ]),
      ),
    );
  }
}
