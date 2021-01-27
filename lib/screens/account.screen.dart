import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/backup/backup_bloc.dart';
import '../blocs/account/account_bloc.dart';
import '../blocs/fiat/fiat_bloc.dart';
import '../screens/currency.screen.dart';
import '../widgets/header.dart';
import '../widgets/backupThumb.dart';
import '../widgets/account_item.dart';
import '../models/account.model.dart';

class AccountScreen extends StatefulWidget {
  final Function jumpTo;
  static const routeName = '/account';

  AccountScreen(this.jumpTo);

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
    return Stack(
      children: [
        BlocBuilder<AccountBloc, AccountState>(
          builder: (context, state) {
            return Container(
              decoration: BoxDecoration(color: Color(0xFFF7F8F9)),
              child: Column(children: [
                Header(),
                BlocBuilder<FiatBloc, FiatState>(builder: (context, fiatState) {
                  FiatLoaded _state;

                  if (fiatState is FiatLoaded) {
                    _state = fiatState;
                  }

                  return Expanded(
                    child: GridView(
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.0,
                          crossAxisSpacing: 4.0),
                      children: state.accounts
                          .map(
                            (Currency acc) => AccountItem(
                              acc,
                              () {
                                Navigator.of(context).pushNamed(
                                    CurrencyScreen.routeName,
                                    arguments: {"account": acc});
                              },
                              fiat: (fiatState is FiatLoaded)
                                  ? _state.fiat
                                  : null,
                            ),
                          )
                          .toList(),
                    ),
                  );
                })
              ]),
            );
          },
        ),
        BlocBuilder<BackupBloc, BackupState>(
          builder: (context, state) {
            if (state is UnBackup) {
              return Positioned(
                child: BackupThumb(() {
                  widget.jumpTo(1);
                }),
                bottom: 30.0,
                left: 10.0,
              );
            } else {
              return SizedBox();
            }
          },
        )
      ],
    );
  }
}
