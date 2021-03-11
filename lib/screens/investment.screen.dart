import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:provider/provider.dart';

import '../blocs/invest/invest_bloc.dart';
import '../models/account.model.dart';
import '../models/investment.model.dart';
import '../widgets/defi_item.dart';
import '../widgets/invest_account_tile.dart';

class InvestmentScreen extends StatefulWidget {
  static const routeName = '/investment';

  @override
  _InvestmentScreenState createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen>
    with TickerProviderStateMixin {
  InvestBloc _bloc;

  TabController _tabController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color _color = Theme.of(context).textTheme.headline1.color;
    TextStyle _textStyle = TextStyle(color: _color);
    return BlocBuilder<InvestBloc, InvestState>(
      cubit: _bloc,
      builder: (_, state) {
        if (state is InvestInitial) {
          return Center(
            child: Text('Loading...'),
          );
        }

        if (state is InvestListSucccess) {
          return Container(
            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
            child: Column(
              children: <Widget>[
                BlocBuilder<InvestBloc, InvestState>(
                  // cubit: _ivtBloc,
                  builder: (_, txState) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                'Assest Values(\$)',
                                style: _textStyle,
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              GestureDetector(
                                child: Icon(
                                  Icons.visibility,
                                  color: _color,
                                  size: 20,
                                ),
                                onTap: () {},
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'My portfolio',
                                  style: _textStyle,
                                )
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Yesterday(\$)+0.01', style: _textStyle),
                              Text(
                                'Total yield(\$)+0.01',
                                style: _textStyle,
                              )
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // TabBar(
                //   tabs: [
                //     Tab(
                //         icon: Text('By Assets',
                //             style: TextStyle(
                //                 color: Theme.of(context).primaryColor))),
                //     Tab(
                //         icon: Text('By Providers',
                //             style: TextStyle(
                //                 color: Theme.of(context).primaryColor))),
                //   ],
                //   controller: _tabController,
                //   indicatorColor: Theme.of(context).primaryColor,
                //   indicatorSize: TabBarIndicatorSize.label,
                // ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
                    child: ListView.builder(
                      itemCount: 0,
                      itemBuilder: (ctx, index) {
                        return Container(
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).backgroundColor,
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
                                  // CircleAvatar(
                                  //   backgroundImage: AssetImage(),
                                  //   radius: 14,
                                  // ),
                                  SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[],
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
                                child: SizedBox(
                                  child: Container(
                                      color: Theme.of(context).dividerColor),
                                  height: 0.5,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: []
                                    .map((ivt) => InvestAccountTile(
                                            ivt['provider'], ivt['asset'], () {
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
                ),
                // Expanded(
                //   child: TabBarView(
                //     controller: _tabController,
                //     children: [
                //       Padding(
                //         padding: const EdgeInsets.symmetric(
                //             horizontal: 8.0, vertical: 16.0),
                //         child: ListView.builder(
                //           itemCount: _hdRepo.accounts.length,
                //           itemBuilder: (ctx, index) {
                //             // TODO: This should be in BLOC
                //             Account acc = _hdRepo.accounts[index];
                //             List<Map> ivts = [];

                //             state.investments.forEach((ivt) {
                //               List<InvestAccount> result = ivt.accounts
                //                   .where(
                //                       (el) => el.account.symbol == acc.symbol)
                //                   .toList();

                //               ivts += result
                //                   .map(
                //                       (e) => {'provider': ivt.name, 'asset': e})
                //                   .toList();
                //             });
                //             return Container(
                //               padding: const EdgeInsets.all(16.0),
                //               margin: const EdgeInsets.symmetric(vertical: 4.0),
                //               decoration: BoxDecoration(
                //                 border: Border.all(
                //                     color: Theme.of(context)
                //                         .dividerColor
                //                         .withOpacity(0.5)),
                //                 borderRadius: BorderRadius.circular(4),
                //               ),
                //               child: Column(
                //                 children: <Widget>[
                //                   Row(
                //                     children: <Widget>[
                //                       CircleAvatar(
                //                         backgroundImage: AssetImage(
                //                           acc.imgUrl,
                //                         ),
                //                         radius: 14,
                //                       ),
                //                       SizedBox(width: 10),
                //                       Column(
                //                         crossAxisAlignment:
                //                             CrossAxisAlignment.start,
                //                         children: <Widget>[
                //                           Text(acc.symbol.toUpperCase()),
                //                           Text(
                //                             'Avalible ${acc.amount}',
                //                             style: Theme.of(context)
                //                                 .textTheme
                //                                 .subtitle2,
                //                           ),
                //                         ],
                //                       ),
                //                     ],
                //                   ),
                //                   Padding(
                //                     padding: const EdgeInsets.symmetric(
                //                         vertical: 12.0),
                //                     child: SizedBox(
                //                       child: Container(
                //                           color:
                //                               Theme.of(context).dividerColor),
                //                       height: 0.5,
                //                     ),
                //                   ),
                //                   Column(
                //                     crossAxisAlignment:
                //                         CrossAxisAlignment.start,
                //                     children: ivts
                //                         .map((ivt) => InvestAccountTile(
                //                                 ivt['provider'], ivt['asset'],
                //                                 () {
                //                               int i = state.investments
                //                                   .indexWhere((element) =>
                //                                       element.name ==
                //                                       ivt['provider']);

                //                               _repo.selectInvestment(
                //                                   state.investments[i]);
                //                               _repo.selectInvestAccount(
                //                                   ivt['asset']);
                //                               Navigator.of(context).pushNamed(
                //                                   InvestmentTransactionScreen
                //                                       .routeName);
                //                             }))
                //                         .toList(),
                //                   ),
                //                 ],
                //               ),
                //             );
                //           },
                //         ),
                //       ),
                //       Padding(
                //         padding: const EdgeInsets.symmetric(
                //             horizontal: 8.0, vertical: 16.0),
                //         child: ListView.builder(
                //           itemCount: state.investments.length,
                //           itemBuilder: (ctx, index) {
                //             return GestureDetector(
                //               child: DefiItem(state.investments[index]),
                //               onTap: () {
                //                 _repo
                //                     .selectInvestment(state.investments[index]);
                //                 Navigator.of(context).pushNamed(
                //                     InvestmentDetailScreen.routeName);
                //               },
                //             );
                //           },
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          );
        }

        return SizedBox();
      },
    );
  }
}
