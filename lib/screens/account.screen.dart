import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../blocs/account/account_bloc.dart';
import '../blocs/fiat/fiat_bloc.dart';
import '../models/account.model.dart';
import '../widgets/header.dart';
import '../widgets/account_item.dart';
import '../helpers/i18n.dart';
import 'toggle_currency.screen.dart';
import 'transaction_list.screen.dart';

final t = I18n.t;

class AccountScreen extends StatefulWidget {
  final Function jumpTo;
  static const routeName = '/account';

  AccountScreen(this.jumpTo);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late AccountBloc _bloc;

  @override
  didChangeDependencies() {
    _bloc = Provider.of<AccountBloc>(context)..add(OverView());
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlocBuilder<AccountBloc, AccountState>(
          bloc: _bloc,
          builder: (context, state) {
            return Container(
              decoration: BoxDecoration(color: Color(0xFFF7F8F9)),
              child: Column(children: [
                Header(),
                BlocBuilder<FiatBloc, FiatState>(builder: (context, fiatState) {
                  if (fiatState is FiatLoaded)
                    return Expanded(
                      child: GridView(
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.0,
                            mainAxisSpacing: 4.0,
                            crossAxisSpacing: 4.0),
                        children: state.accounts
                            .map(
                              (Account acc) => AccountItem(
                                acc,
                                () {
                                  Navigator.of(context).pushNamed(
                                      TransactionListScreen.routeName,
                                      arguments: {"account": acc});
                                },
                                fiat: fiatState.fiat,
                              ),
                            )
                            .toList(),
                      ),
                    );
                  return SizedBox();
                })
              ]),
            );
          },
        ),
        Positioned(
          child: InkWell(
            onTap: () {
              // Currency currency = _currencies[_currencies.indexWhere(
              //     (curr) => curr.blockchainId.toUpperCase() == '8000025B')];
              // Navigator.of(context).pushNamed(AddCurrencyScreen.routeName,
              //     arguments: {"account": currency});

              Navigator.of(context).pushNamed(ToggleCurrencyScreen.routeName);
            },
            child: Container(
              child: Text(
                '+ ${t('add_currency')}',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          top: 170.0,
          right: 12.0,
        ),
      ],
    );
  }
}
