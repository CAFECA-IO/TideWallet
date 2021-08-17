import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/account/account_bloc.dart';
import '../blocs/fiat/fiat_bloc.dart';
import '../helpers/formatter.dart';

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(builder: (ctx, state) {
      return BlocBuilder<FiatBloc, FiatState>(builder: (context, fiatState) {
        late FiatLoaded _state;
        bool fiatReady = false;

        if (fiatState is FiatLoaded) {
          _state = fiatState;
          fiatReady = true;
        }
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
                children: fiatReady
                    ? [
                        TextSpan(
                          text:
                              ' ${Formatter.formatDecimal(state.totalBalanceInFiat, decimalLength: 2)} ',
                          style: Theme.of(context)
                              .textTheme
                              .headline5!
                              .copyWith(fontSize: 36.0),
                        ),
                        TextSpan(text: _state.fiat.name)
                      ]
                    : [],
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(color: Colors.white)),
          ),
        );
      });
    });
  }
}
