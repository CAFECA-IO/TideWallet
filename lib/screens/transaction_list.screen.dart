import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../repositories/transaction_repository.dart';
import '../repositories/trader_repository.dart';
import './create_transaction.screen.dart';
import './receive.screen.dart';
import '../models/account.model.dart';
import '../models/transaction.model.dart';
import '../blocs/fiat/fiat_bloc.dart';
import '../blocs/transaction_status/transaction_status_bloc.dart';
import '../widgets/appBar.dart';
import '../widgets/buttons/tertiary_button.dart';
import '../widgets/transaction_item.dart';

import '../helpers/formatter.dart';
import '../helpers/i18n.dart';
import '../theme.dart';

class TransactionListScreen extends StatefulWidget {
  static const routeName = '/transaction-list';

  @override
  _TransactionListScreenState createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final t = I18n.t;
  TransactionStatusBloc _bloc;
  TransactionRepository _repo;
  TraderRepository _traderRepo;
  Currency _currency;

  @override
  void didChangeDependencies() {
    Map<String, Currency> arg = ModalRoute.of(context).settings.arguments;
    _currency = arg["account"];
    _repo = Provider.of<TransactionRepository>(context);
    _traderRepo = Provider.of<TraderRepository>(context);
    _bloc = TransactionStatusBloc(_repo, _traderRepo)
      ..add(UpdateCurrency(_currency));
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
        title: '',
        routeName: TransactionListScreen.routeName,
      ),
      body: BlocBuilder<TransactionStatusBloc, TransactionStatusState>(
          cubit: _bloc,
          builder: (context, state) {
            return Container(
              child: Column(children: [
                Container(
                  width: double.infinity,
                  // height: 300.0,
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
                    // Spacer(),
                    SizedBox(height: 100),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: MyColors.font_01, shape: BoxShape.circle),
                      child: Image.asset(
                        state.currency?.imgPath ?? _currency.imgPath,
                        width: 32.0,
                        height: 32.0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        state.currency?.symbol?.toUpperCase() ??
                            _currency.symbol,
                        style: Theme.of(context).textTheme.button,
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                          '${Formatter.formatDecimal(state.currency?.amount ?? _currency.amount)}',
                          style: Theme.of(context).textTheme.headline4),
                    ),
                    BlocBuilder<FiatBloc, FiatState>(
                        builder: (context, fiatState) {
                      FiatLoaded _state;
                      String value = '';

                      if (fiatState is FiatLoaded) {
                        _state = fiatState;
                        String num = state.currency?.inUSD ?? _currency.inUSD;
                        value = Formatter.formatDecimal(
                            (Decimal.tryParse(num) / _state.fiat.exchangeRate)
                                .toString());
                      }
                      return Text(
                        '${String.fromCharCode(0x2248)} $value ${_state.fiat.name}',
                        style: Theme.of(context).textTheme.button,
                      );
                    }),
                    SizedBox(height: 24),
                  ]),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                          bottom: BorderSide(
                              color: Theme.of(context).dividerColor))),
                  child: Row(
                    children: [
                      Expanded(
                          child: TertiaryButton(
                        t('send'),
                        () {
                          Navigator.of(context).pushNamed(
                              CreateTransactionScreen.routeName,
                              arguments: {"account": _currency});
                        },
                        textColor: MyColors.primary_04,
                        iconImg:
                            AssetImage('assets/images/icons/ic_send_black.png'),
                      )),
                      Expanded(
                          child: TertiaryButton(
                        t('receive'),
                        () {
                          Navigator.of(context).pushNamed(
                              ReceiveScreen.routeName,
                              arguments: {"currency": state.currency});
                        },
                        textColor: MyColors.primary_03,
                        iconImg: AssetImage(
                            'assets/images/icons/ic_receive_black.png'),
                      )),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: ListView.builder(
                        itemCount: state?.transactions?.length ?? 0,
                        itemBuilder: (context, index) {
                          Transaction transaction = state.transactions[index];
                          Currency currency = state.currency;
                          return TransactionItem(
                              currency: currency, transaction: transaction);
                        },
                      ),
                    ),
                  ),
                )
              ]),
            );
          }),
    );
  }
}
