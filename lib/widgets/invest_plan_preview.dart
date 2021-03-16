import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tidewallet3/widgets/buttons/secondary_button.dart';

import '../models/investment.model.dart';
import '../models/account.model.dart';
import '../blocs/invest_plan/invest_plan_bloc.dart';
import '../widgets/buttons/primary_button.dart';

import '../helpers/i18n.dart';

class InvestPlanPreview extends StatefulWidget {
  final Currency currency;
  final Investment investment;

  const InvestPlanPreview({Key key, this.currency, this.investment})
      : super(key: key);
  @override
  _InvestPlanPreviewState createState() => _InvestPlanPreviewState();
}

class _InvestPlanPreviewState extends State<InvestPlanPreview> {
  final t = I18n.t;

  InvestPlanBloc _bloc;

  @override
  void didChangeDependencies() {
    this._bloc = BlocProvider.of<InvestPlanBloc>(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    // _bloc.close();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return
        // BlocListener(
        //   cubit: _bloc,
        //   listener: (BuildContext context, state) {},
        //   child:
        Container(
      constraints: BoxConstraints(maxHeight: size.height * 0.7),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
      child: Column(
        children: [
          Container(
            child: Align(
              child: Text(
                t('expected_trial'),
                style: Theme.of(context).textTheme.subtitle1,
              ),
              alignment: Alignment.centerLeft,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Align(
                  child: Text(
                    t('invest_account') + " :",
                  ),
                  alignment: Alignment.centerLeft,
                ),
              ),
              Container(
                child: Align(
                  child: Text(
                    widget.currency.name,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  alignment: Alignment.centerLeft,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Align(
                  child: Text(
                    t('invest_amount') + " :",
                  ),
                  alignment: Alignment.centerLeft,
                ),
              ),
              Container(
                child: Align(
                  child: Text(
                    widget.investment.investAmount.toString() +
                        " " +
                        widget.currency.symbol,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  alignment: Alignment.centerLeft,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Align(
                  child: Text(
                    t('invest_strategy') + " :",
                  ),
                  alignment: Alignment.centerLeft,
                ),
              ),
              Container(
                child: Align(
                  child: Text(
                    t(widget.investment.investStrategy.value),
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  alignment: Alignment.centerLeft,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Align(
                  child: Text(
                    t('service_fee') + " :",
                  ),
                  alignment: Alignment.centerLeft,
                ),
              ),
              Container(
                child: Align(
                  child: Text(
                    widget.investment.fee.toString() +
                        " " +
                        widget.currency.symbol,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  alignment: Alignment.centerLeft,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Align(
                  child: Text(
                    t('estimate_profit') + " :",
                  ),
                  alignment: Alignment.centerLeft,
                ),
              ),
              Container(
                child: Align(
                  child: Text(
                    widget.investment.estimateProfit.toString() +
                        " " +
                        widget.currency.symbol,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  alignment: Alignment.centerLeft,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Align(
                  child: Text(
                    t('irr') + " :",
                  ),
                  alignment: Alignment.centerLeft,
                ),
              ),
              Container(
                child: Align(
                  child: Text(
                    (widget.investment.iRR * Decimal.fromInt(100)).toString() +
                        " %",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  alignment: Alignment.centerLeft,
                ),
              ),
            ],
          ),
          Spacer(),
          PrimaryButton(t('authorize'), () {
            this._bloc.add(CreateInvestPlan());
            Navigator.of(context).pop();
          }),
          SizedBox(height: 10),
          SecondaryButton(
            t('cancel'),
            () {
              Navigator.of(context).pop();
            },
            borderColor: Theme.of(context).primaryColor,
          ),
          SizedBox(height: 20),
        ],
      ),
      // ),
    );
  }
}
