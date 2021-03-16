import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../models/investment.model.dart';
import '../models/account.model.dart';

import '../blocs/invest_plan/invest_plan_bloc.dart';
import '../blocs/verify_password/verify_password_bloc.dart';

import '../repositories/user_repository.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';

import '../helpers/i18n.dart';
import 'dialogs/dialog_controller.dart';
import 'dialogs/error_dialog.dart';
import 'dialogs/verify_password_dialog.dart';

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
  VerifyPasswordBloc _verifyPasswordBloc;
  UserRepository _userRepo;

  @override
  void didChangeDependencies() {
    this._bloc = BlocProvider.of<InvestPlanBloc>(context);
    _userRepo = Provider.of<UserRepository>(context, listen: false);

    this._verifyPasswordBloc = VerifyPasswordBloc(this._userRepo);

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
          BlocListener<VerifyPasswordBloc, VerifyPasswordState>(
            cubit: _verifyPasswordBloc,
            listener: (context, state) {
              if (state is PasswordVerified) {
                this._bloc.add(CreateInvestPlan());
                Navigator.of(context).pop();
              }
              if (state is PasswordInvalid) {
                DialogController.show(
                    context, ErrorDialog(t('error_password')));
              }
            },
            child: PrimaryButton(t('authorize'), () {
              DialogController.showUnDissmissible(
                context,
                VerifyPasswordDialog((String password) {
                  _verifyPasswordBloc.add(VerifyPassword(password));
                  DialogController.dismiss(context);
                }, (String password) {
                  DialogController.dismiss(context);
                }),
              );
            }),
          ),
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
