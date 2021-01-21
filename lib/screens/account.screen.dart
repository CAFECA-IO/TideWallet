import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tidewallet3/screens/currency.screen.dart';

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
        return Container(
          decoration: BoxDecoration(color: Color(0xFFF7F8F9)),
          child: Column(children: [
            Container(
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(bottom: 58.0),
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
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: '≈',
                    children: [
                      TextSpan(text: state.total.toString(), style: Theme.of(context).textTheme.headline5.copyWith(fontSize: 36.0, letterSpacing: 20.0)),
                      TextSpan(text: 'USD')
                    ],
                    style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white)),
              ),
            ),
            Expanded(
              child: GridView(
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 4.0),
                children: state.accounts
                    .map((Currency acc) => AccountItem(acc, () {
                      Navigator.of(context).pushNamed(CurrencyScreen.routeName, arguments: {
                        "account": acc
                      });
                    }))
                    .toList(),
              ),
            )
          ]),
        );
      },
    );
  }
}
