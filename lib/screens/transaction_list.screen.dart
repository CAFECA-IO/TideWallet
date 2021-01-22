import 'package:flutter/material.dart';
import '../widgets/appBar.dart';

import '../helpers/i18n.dart';

class TransactionListScreen extends StatelessWidget {
  static const routeName = '/transaction-list';
  final t = I18n.t;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: GeneralAppbar(
            title: '',
            routeName: TransactionListScreen.routeName,
          ),
          body: Container(
            child: Column(children: [
              Container(
                width: double.infinity,
                height: 256.0,
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
                child: Column(children: [
                  Container(
                    child: Image.asset(
                      '',
                      width: 26.0,
                      height: 26.0,
                    ),
                  )
                ]),
              ),
              TabBar(
                tabs: [
                  Tab(
                    text: t('send'),
                  ),
                  Tab(
                    text: t('receive'),
                  )
                ],
              ),
              Expanded(
                child: TabBarView(children: [
                  // ListView(children: []),
                  Text('text'),
                  Text('text'),
                ]),
              )
            ]),
          )),
    );
  }
}
