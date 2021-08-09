import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../models/investment.model.dart';
import '../models/account.model.dart';

import '../blocs/invest_plan/invest_plan_bloc.dart';
import '../blocs/verify_password/verify_password_bloc.dart';
import '../blocs/local_auth/local_auth_bloc.dart';

import '../repositories/local_auth_repository.dart';
import '../repositories/user_repository.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';

import '../helpers/i18n.dart';
import 'dialogs/dialog_controller.dart';
import 'dialogs/error_dialog.dart';

class InvestPlanPreview extends StatefulWidget {
  final Currency currency;
  final Investment investment;

  const InvestPlanPreview(
      {Key? key, required this.currency, required this.investment})
      : super(key: key);
  @override
  _InvestPlanPreviewState createState() => _InvestPlanPreviewState();
}

class _InvestPlanPreviewState extends State<InvestPlanPreview> {
  final t = I18n.t;

  late InvestPlanBloc _bloc;
  late LocalAuthBloc _localBloc;
  late UserRepository _userRepo;

  @override
  void didChangeDependencies() {
    this._bloc = BlocProvider.of<InvestPlanBloc>(context);
    _userRepo = Provider.of<UserRepository>(context, listen: false);

    _localBloc = LocalAuthBloc(LocalAuthRepository());

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
        //   bloc: _bloc,
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
          BlocListener<LocalAuthBloc, LocalAuthState>(
            bloc: _localBloc,
            listener: (context, state) {
              if (state is AuthenticationStatus) {
                if (state.isAuthenicated) {
                  this._bloc.add(CreateInvestPlan(_userRepo.getPassword()));
                  Navigator.of(context).pop();
                } else {
                  // ++ [Emily 4/1/2021]
                }
              }
            },
            child: PrimaryButton(
              t('authorize'),
              () {
                this._localBloc.add(Authenticate());
              },
            ),
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
