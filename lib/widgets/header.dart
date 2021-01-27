import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/account/account_bloc.dart';

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(builder: (ctx, state) {

      return Container(
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
                TextSpan(
                  text: ' ${state.total.toString()} ',
                  style: Theme.of(context)
                      .textTheme
                      .headline5
                      .copyWith(fontSize: 36.0),
                ),
                TextSpan(text: 'USD')
              ],
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .copyWith(color: Colors.white)),
        ),
      );
    });
  }
}
