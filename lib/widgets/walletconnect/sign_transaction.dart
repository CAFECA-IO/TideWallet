import 'dart:math';
// import 'package:flutter/foundation.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../models/account.model.dart';
import '../../repositories/trader_repository.dart';
import '../../helpers/utils.dart';
import '../../blocs/fiat/fiat_bloc.dart';
import '../../helpers/formatter.dart';
import '../../widgets/buttons/primary_button.dart';

class SignTransaction extends StatefulWidget {
  final BuildContext context;
  final String dapp;
  final Map param;
  final Function cancel;
  final Function submit;
  final Currency currency;

  SignTransaction({
    @required this.context,
    @required this.dapp,
    @required this.param,
    @required this.submit,
    @required this.cancel,
    @required this.currency,
  });

  @override
  _SignTransactionState createState() => _SignTransactionState();
}

class _SignTransactionState extends State<SignTransaction> {
  FiatBloc _fiatBloc;
  TraderRepository _traderRepo;

  @override
  void didChangeDependencies() {
    _fiatBloc = BlocProvider.of<FiatBloc>(context);
    _traderRepo = Provider.of<TraderRepository>(context);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Decimal amount = hexStringToDecimal(widget.param['value']);
    Decimal fee = hexStringToDecimal(widget.param['gasPrice']) *
        hexStringToDecimal(widget.param['gas']) /
        Decimal.fromInt(pow(10, 18));
    Decimal amountInFiat =
        _traderRepo.calculateAmountToFiat(widget.currency, amount);
    Decimal feeInFiat = _traderRepo.calculateAmountToFiat(widget.currency, fee);

    bool able = (Decimal.tryParse(widget.currency.amount) *
                Decimal.fromInt(pow(10, 18)) -
            amount -
            fee) >
        Decimal.zero;

    return BlocBuilder<FiatBloc, FiatState>(
        cubit: _fiatBloc,
        builder: (context, state) {
          String fiat = '';
          if (state is FiatLoaded) {
            fiat = state.fiat.name;
          }
          return Container(
            decoration: BoxDecoration(),
            padding: EdgeInsets.only(
              top: MediaQuery.of(widget.context).padding.top,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 14.0),
                  decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0))),
                  child: Row(
                    children: [
                      InkWell(
                        child: Text('取消',
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                .copyWith(fontSize: 18.0)),
                        onTap: () {
                          this.widget.cancel();
                        },
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/icons/ic_send_black.png',
                        width: 40.0,
                        color: Theme.of(context).textTheme.caption.color,
                      ),
                      SizedBox(
                        width: 4.0,
                      ),
                      Text(
                        '- $amount ETH',
                        style: Theme.of(context).textTheme.headline1,
                      ),
                      Text('(\$ $amountInFiat $fiat)')
                    ],
                  ),
                ),
                TxItem('從',
                    '主錢包(${Formatter.formatAdddress(widget.param['from'], showLength: 14)})'),
                TxItem('DAPP', widget.dapp),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 12.0),
                  child: Row(
                    children: [
                      Text(
                        '網路費用',
                        style: Theme.of(context)
                            .textTheme
                            .headline1
                            .copyWith(fontSize: 16),
                      ),
                      Spacer(),
                      Text(' $fee ETH'),
                      Text(
                          '(\$ ${Formatter.formatDecimal(feeInFiat.toString())} $fiat)')
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  padding: const EdgeInsets.all(12.0),
                  color: Theme.of(context).dividerColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '最大總計',
                        style: Theme.of(context)
                            .textTheme
                            .headline1
                            .copyWith(fontSize: 18),
                      ),
                      Text('\$ ${amountInFiat + feeInFiat} $fiat')
                    ],
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Color(0xFFECF5FF),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14.0, vertical: 13.0),
                    child: Text(
                      '請確保您信任此應用程式。我們不用對此應用程式內的任何操作負責。',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 50.0),
                  child: PrimaryButton(
                    '發送',
                    able
                        ? () {
                            this.widget.submit();
                          }
                        : null,
                    disableColor: Theme.of(context).disabledColor,
                    borderColor: able
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).disabledColor,
                  ),
                )
              ],
            ),
          );
        });
  }
}

class TxItem extends StatelessWidget {
  final String _title;
  final String _value;

  TxItem(this._title, this._value);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_title,
              style:
                  Theme.of(context).textTheme.headline1.copyWith(fontSize: 16)),
          SizedBox(
            height: 6.0,
          ),
          Text(
            _value,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
