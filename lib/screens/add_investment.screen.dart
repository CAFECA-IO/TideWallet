import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cores/account.dart';

import '../models/investment.model.dart';
import '../models/account.model.dart';

import '../blocs/invest_plan/invest_plan_bloc.dart';

import '../widgets/appBar.dart';
import '../widgets/inputs/input.dart';
import '../widgets/buttons/radio_button.dart';
import '../widgets/item_picker.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/invest_plan_preview.dart';
import '../widgets/dialogs/dialog_controller.dart';
import '../widgets/dialogs/error_dialog.dart';
import '../widgets/dialogs/loading_dialog.dart';

import '../helpers/logger.dart';
import '../helpers/i18n.dart';

import '../theme.dart';

final t = I18n.t;

class AddInvestmentScreen extends StatefulWidget {
  static const routeName = '/add-investment';
  @override
  _AddInvestmentScreenState createState() => _AddInvestmentScreenState();
}

class _AddInvestmentScreenState extends State<AddInvestmentScreen> {
  bool _isSelected = false;
  TextEditingController _controller = TextEditingController();
  late InvestPlanBloc _bloc;
  int index = 1;
  late Account? _account;
  late InvestStrategy? _strategy;
  late InvestAmplitude? _amplitude;
  late InvestPercentage? _percentage;

  @override
  void didChangeDependencies() {
    this._bloc = BlocProvider.of<InvestPlanBloc>(context)
      ..add(InvestPlanInitialed(AccountCore().accountList[0],
          InvestStrategy.Climb, InvestAmplitude.Normal, InvestPercentage.Low));
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: GeneralAppbar(
        title: t('add_invest_plan'),
        routeName: AddInvestmentScreen.routeName,
      ),
      body: BlocBuilder<InvestPlanBloc, InvestPlanState>(
          bloc: _bloc,
          builder: (context, state) {
            if (state is InvestPlanInitial)
              return Expanded(
                child: Center(
                  child: Text('Loading...'),
                ),
              );
            else {
              if (state is InvestPlanStatus) {
                _account = state.account;
                _strategy = state.strategy;
                _amplitude = state.amplitude;
                _percentage = state.percentage;
              }
              return BlocListener(
                bloc: _bloc,
                listener: (context, state) {
                  if (state is InvestLoading) {
                    DialogController.showUnDissmissible(
                        context, LoadingDialog());
                  }
                  if (state is InvestSuccess) {
                    DialogController.dismiss(context);
                    Navigator.of(context).pop();
                  }
                  if (state is InvestFail) {
                    DialogController.dismiss(context);
                    DialogController.show(
                        context, ErrorDialog('Something went wrong...'));
                  }
                  if (state is InvestPlanStatus && state.investment != null) {
                    DialogController.dismiss(context);
                    showModalBottomSheet(
                      isScrollControlled: true,
                      shape: bottomSheetShape,
                      context: context,
                      builder: (context) => Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 22.0, horizontal: 16.0),
                        child: InvestPlanPreview(
                            account: state.account,
                            investment: state.investment!),
                      ),
                    );
                  }
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 16),
                  child: Column(children: [
                    Container(
                      child: Align(
                        child: Text(
                          t('choose_invest_account'),
                          // style: Theme.of(context).textTheme.subtitle1,
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    ItemPicker(
                      title: t('invest_account'),
                      items: AccountCore().accountList,
                      selectedItem: _account ?? AccountCore().accountList[0],
                      onTap: () {},
                      notifyParent: ({required int index, dynamic value}) {
                        _bloc.add(AccountSelected(value));
                      },
                    ),
                    SizedBox(height: 32),
                    Container(
                      child: Align(
                        child: Text(
                          t('choose_invest_strategy'),
                          // style: Theme.of(context).textTheme.subtitle1,
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    ItemPicker(
                      title: t('invest_strategy'),
                      items:
                          InvestStrategy.values.map((e) => t(e.value)).toList(),
                      selectedItem:
                          t(_strategy?.value ?? InvestStrategy.values[0].value),
                      onTap: () {},
                      notifyParent: ({required int index, dynamic value}) {
                        _bloc.add(
                            StrategySetected(InvestStrategy.values[index]));
                      },
                    ),
                    SizedBox(height: 32),
                    Container(
                      child: Align(
                        child: Text(
                          t('choose_invest_amplitude'),
                          // style: Theme.of(context).textTheme.subtitle1,
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    SizedBox(height: 10),
                    RadioGroupButton(
                      _amplitude?.index ?? 1,
                      InvestAmplitude.values
                          .map(
                            (amplitude) => [
                              t(amplitude.value),
                              () {
                                _bloc.add(AmplitudeSelected(amplitude));
                                Log.debug(amplitude);
                              }
                            ],
                          )
                          .toList(),
                    ),
                    SizedBox(height: 20),
                    Container(
                      child: Align(
                        child: Text(
                          t('choose_invest_amount'),
                          // style: Theme.of(context).textTheme.subtitle1,
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    SizedBox(height: 10),
                    _isSelected
                        ? Column(
                            children: [
                              Container(
                                child: Align(
                                  child: Text(
                                    '請輸入0～100之間的數字',
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                  alignment: Alignment.centerLeft,
                                ),
                              ),
                              SizedBox(height: 10),
                              // Row(
                              //   mainAxisAlignment:
                              //       MainAxisAlignment.spaceBetween,
                              //   children: [
                              Input(
                                inputFormatter: [
                                  FilteringTextInputFormatter.deny(
                                      RegExp(r"\s")),
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'(^\d*\.?\d*)$')),
                                ],
                                labelText: t('invest_percentage'),
                                autovalidate: AutovalidateMode.disabled,
                                controller: _controller,
                                onChanged: (String v) {
                                  this
                                      ._bloc
                                      .add(InputPercentage(_controller.text));
                                },
                                keyboardType: TextInputType.number,
                              ),
                              // SizedBox(width: 8),
                              // Container(
                              //     child: Text(
                              //   '%',
                              //   style: Theme.of(context).textTheme.caption,
                              // )),
                            ],
                          )
                        //   ],
                        // )
                        : RadioGroupButton(
                            _percentage?.index ?? 0,
                            InvestPercentage.values
                                .map(
                                  (percentage) => [
                                    percentage.value + '%',
                                    () {
                                      _bloc.add(PercentageSelected(percentage));
                                      _controller.text =
                                          (Decimal.tryParse(percentage.value)! /
                                                  Decimal.fromInt(100))
                                              .toString();
                                      Log.debug(percentage.value);
                                    }
                                  ],
                                )
                                .toList(),
                          ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          t('advanced_settings'),
                          style: Theme.of(context).textTheme.caption,
                        ),
                        // SizedBox(width: 5),
                        Switch(
                          activeColor: Theme.of(context).primaryColor,
                          value: _isSelected,
                          onChanged: (bool newValue) {
                            setState(() {
                              _isSelected = newValue;
                            });
                          },
                        ),
                      ],
                    ),
                    // Spacer(),
                    SizedBox(height: 40),
                    Container(
                      padding: EdgeInsets.only(bottom: 48),
                      margin: EdgeInsets.symmetric(horizontal: 36),
                      child: SecondaryButton(
                        t('next'),
                        () async {
                          _bloc.add(GenerateInvestPlan());
                        },
                        textColor: Theme.of(context).accentColor,
                        borderColor: Theme.of(context).accentColor,
                      ),
                    ),
                  ]),
                ),
              );
            }
          }),
    );
  }
}
