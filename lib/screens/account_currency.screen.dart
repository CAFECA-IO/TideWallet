import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../blocs/backup/backup_bloc.dart';
import '../blocs/account_currency/account_currency_bloc.dart';
import '../blocs/fiat/fiat_bloc.dart';
import '../widgets/header.dart';
import '../widgets/backupThumb.dart';
import '../widgets/account_item.dart';
import '../models/account.model.dart';
import '../repositories/trader_repository.dart';
import '../repositories/account_repository.dart';
import '../helpers/i18n.dart';
import 'currency.screen.dart';
import 'transaction_list.screen.dart';
import 'add_currency.screen.dart';

final t = I18n.t;

class AccountCurrencyScreen extends StatefulWidget {
  final Function jumpTo;
  static const routeName = '/account';

  AccountCurrencyScreen(this.jumpTo);

  @override
  _AccountCurrencyScreenState createState() => _AccountCurrencyScreenState();
}

class _AccountCurrencyScreenState extends State<AccountCurrencyScreen> {
  AccountCurrencyBloc _bloc;
  AccountRepository _repo;
  TraderRepository _traderRepo;
  List<Currency> _currencies;

  @override
  didChangeDependencies() {
    _repo = Provider.of<AccountRepository>(context);
    _traderRepo = Provider.of<TraderRepository>(context);

    _bloc = AccountCurrencyBloc(_repo, _traderRepo)..add(GetCurrencyList());
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlocBuilder<AccountCurrencyBloc, AccountCurrencyState>(
          cubit: _bloc,
          builder: (context, state) {
            _currencies = state.currencies;
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
                      children: state.currencies
                          .map(
                            (Currency acc) => AccountItem(
                              acc,
                              () {
                                Navigator.of(context).pushNamed(
                                    TransactionListScreen.routeName,
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
                  widget.jumpTo(3);
                }),
                bottom: 30.0,
                left: 10.0,
              );
            } else {
              return SizedBox();
            }
          },
        ),
        Positioned(
          child: InkWell(
            onTap: () {
              Currency currency = _currencies[_currencies.indexWhere(
                  (curr) => curr.blockchainId.toUpperCase() == '8000025B')];
              Navigator.of(context).pushNamed(AddCurrencyScreen.routeName,
                  arguments: {"account": currency});
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
