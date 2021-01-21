import 'package:flutter/material.dart';
import 'package:tidewallet3/models/account.model.dart';

class AccountItem extends StatelessWidget {
  final Account _account; 
  final ACCOUNT_TYPE type;

  AccountItem(this._account, { this.type = ACCOUNT_TYPE.currency });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(_account.imgPath, width: 26.0, height: 26.0,),
          SizedBox(height: 4.0),
          Text(_account.symbol),
          Text(_account.amount),
          Text('≈ ${_account.fiat} USD', style: Theme.of(context).textTheme.subtitle2)
        ]
      ),
    );
  }
}