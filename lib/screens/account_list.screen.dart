import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../blocs/account_list/account_list_bloc.dart';
import '../blocs/fiat/fiat_bloc.dart';
import '../models/account.model.dart';
import '../widgets/header.dart';
import '../widgets/account_item.dart';
import '../helpers/i18n.dart';
import 'toggle_token.screen.dart';
import 'account_detial.screen.dart';

final t = I18n.t;

class AccountListScreen extends StatefulWidget {
  final Function jumpTo;
  static const routeName = '/account';

  AccountListScreen(this.jumpTo);

  @override
  _AccountListScreenState createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  late AccountListBloc _bloc;

  @override
  didChangeDependencies() {
    _bloc = Provider.of<AccountListBloc>(context)..add(OverView());
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlocBuilder<AccountListBloc, AccountListState>(
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
                                      AccountDetailScreen.routeName,
                                      arguments: {"accountId": acc.id});
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
              Navigator.of(context).pushNamed(ToggleTokenScreen.routeName);
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
