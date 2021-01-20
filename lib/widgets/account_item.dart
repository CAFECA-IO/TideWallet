import 'package:flutter/material.dart';
import 'package:tidewallet3/models/account.model.dart';

class AccountItem extends StatelessWidget {
  final Account _account; 

  AccountItem(this._account);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(_account.symbol),
          Text(_account.amount),
          Text('≈ ${_account.fiat} USD')
        ]
      ),
    );
  }
}