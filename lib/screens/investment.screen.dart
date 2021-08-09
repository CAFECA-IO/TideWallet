import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../blocs/invest/invest_bloc.dart';
import '../models/account.model.dart';
import '../models/investment.model.dart';
import '../widgets/header.dart';
import '../widgets/invest_account_tile.dart';
import '../helpers/i18n.dart';

import 'add_investment.screen.dart';

final t = I18n.t;

class InvestmentScreen extends StatefulWidget {
  static const routeName = '/investment';

  @override
  _InvestmentScreenState createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen>
    with TickerProviderStateMixin {
  late InvestBloc _ivtBloc;

  @override
  void didChangeDependencies() {
    _ivtBloc = Provider.of<InvestBloc>(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _ivtBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          child: Column(
            children: <Widget>[
              Header(), // TODO do anotherHeader for investment
              BlocBuilder<InvestBloc, InvestState>(
                bloc: _ivtBloc,
                builder: (_, state) {
                  if (state is InvestInitial) {
                    return Expanded(
                      child: Center(
                        child: Text('Loading...'),
                      ),
                    );
                  }
                  if (state is ListInvestments) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: state.investAccounts.length,
                          itemBuilder: (ctx, index) {
                            InvestAccount investAccount =
                                state.investAccounts[index];
                            Currency currency = investAccount.currency;
                            List<Investment> investments =
                                investAccount.investments;
                            return Container(
                              padding: const EdgeInsets.fromLTRB(
                                  16.0, 16.0, 16.0, 0),
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: Theme.of(context)
                                        .dividerColor
                                        .withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(currency.imgPath),
                                        radius: 14,
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(currency.symbol.toUpperCase()),
                                          Text(
                                            'Avalible ${currency.amount}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0),
                                    child: SizedBox(
                                      child: Container(
                                          color:
                                              Theme.of(context).dividerColor),
                                      height: 0.5,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: investments
                                        .map((investment) => InvestAccountTile(
                                                currency, investment, () {
                                              //TODO
                                            }))
                                        .toList(),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }
                  return SizedBox();
                },
              ),
            ],
          ),
        ),
        Positioned(
          child: InkWell(
            onTap: () {
              // showModalBottomSheet(
              //   isScrollControlled: true,
              //   shape: bottomSheetShape,
              //   context: context,
              //   builder: (context) => Container(
              //     padding:
              //         EdgeInsets.symmetric(vertical: 22.0, horizontal: 16.0),
              //     child: CreateInvestPlanForm(),
              //   ),
              // );
              Navigator.of(context).pushNamed(AddInvestmentScreen.routeName);
            },
            child: Container(
              child: Text(
                '+ ${t('add_invest_plan')}',
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
