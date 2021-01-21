import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/account/account_bloc.dart';
import '../models/account.model.dart';
import '../widgets/account_item.dart';

class AccountScreen extends StatefulWidget {
  static const routeName = '/account';

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {

  @override
  didChangeDependencies() {

    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        return Column(children: [
          Container(
            width: double.infinity,
            height: 200.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Theme.of(context).primaryColor,
                  Theme.of(context).accentColor
                ],
              ),
            ),
            child: Column(children: [Text('≈ ')]),
          ),
          Expanded(
            child: ListView(children: state.accounts.map((Account acc) => AccountItem(acc)).toList()),
          )
        ]);
      },
    );
  }
}
