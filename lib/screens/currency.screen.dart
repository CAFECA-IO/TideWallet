import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../blocs/currency/currency_bloc.dart';
import '../blocs/fiat/fiat_bloc.dart';
import '../models/account.model.dart';
import '../screens/add_currency.screen.dart';
import '../repositories/trader_repository.dart';
import '../repositories/account_repository.dart';
import '../screens/transaction_list.screen.dart';
import '../widgets/appBar.dart';
import '../widgets/account_item.dart';
import '../helpers/i18n.dart';
import '../helpers/formatter.dart';

final t = I18n.t;

class CurrencyScreen extends StatefulWidget {
  static const routeName = '/Currency';
  @override
  _CurrencyScreenState createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  CurrencyBloc _bloc;
  AccountRepository _repo;
  TraderRepository _traderRepo;
  @override
  void didChangeDependencies() {
    Map<String, Currency> arg = ModalRoute.of(context).settings.arguments;
    _repo = Provider.of<AccountRepository>(context);
    _traderRepo = Provider.of<TraderRepository>(context);
    _bloc = CurrencyBloc(_repo, _traderRepo)
      ..add(GetCurrencyList(arg['account'].accountType));
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GeneralAppbar(
        routeName: CurrencyScreen.routeName,
      ),
      body: BlocBuilder<CurrencyBloc, CurrencyState>(
        cubit: _bloc,
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(color: Color(0xFFF7F8F9)),
            child:
                BlocBuilder<FiatBloc, FiatState>(builder: (context, fiatState) {
              FiatLoaded _state;
              bool fiatReady = false;

              if (fiatState is FiatLoaded) {
                _state = fiatState;
                fiatReady = true;
              }
              return Column(children: [
                Stack(
                  children: [
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
                            children: fiatReady
                                ? [
                                    TextSpan(
                                      text:
                                          ' ${Formatter.formateDecimal((state.total / _state.fiat.exchangeRate).toString(), decimalLength: 2)} ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5
                                          .copyWith(fontSize: 36.0),
                                    ),
                                    TextSpan(text: _state.fiat.name)
                                  ]
                                : [],
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(color: Colors.white)),
                      ),
                    ),
                    Positioned(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(AddCurrencyScreen.routeName);
                          },
                          child: Container(
                            child: Text(
                              '+ ${t('add_currency')}',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        bottom: 12.0,
                        right: 12.0)
                  ],
                ),
                Expanded(
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
                            fiat: _state.fiat,
                          ),
                        )
                        .toList(),
                  ),
                )
              ]);
            }),
          );
        },
      ),
    );
  }
}
