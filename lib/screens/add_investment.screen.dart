import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:tidewallet3/cores/account.dart';

import '../models/investment.model.dart';
import '../blocs/invest_plan/invest_plan_bloc.dart';
import '../repositories/invest_repository.dart';
import '../widgets/appBar.dart';
import '../widgets/inputs/input.dart';
import '../widgets/buttons/radio_button.dart';
import '../widgets/item_picker.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/invest_plan_preview.dart';

import '../widgets/buttons/primary_button.dart';
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
  InvestRepository _repo;
  InvestPlanBloc _bloc;

  @override
  void didChangeDependencies() {
    this._repo = Provider.of<InvestRepository>(context);
    this._bloc = InvestPlanBloc(this._repo)
      ..add(InvestPlanInitialed(AccountCore().getAllCurrencies()[0],
          InvestStrategy.Climb, InvestAmplitude.Normal, '10'));
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: GeneralAppbar(
        routeName: AddInvestmentScreen.routeName,
      ),
      body: BlocBuilder<InvestPlanBloc, InvestPlanState>(
        cubit: _bloc,
        builder: (context, state) {
          if (state is InvestPlanInitial) {
            return Expanded(
              child: Center(
                child: Text('Loading...'),
              ),
            );
          }
          if (state is InvestPlanStatus) {
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
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
                  items: AccountCore().getAllCurrencies(),
                  selectedItem: state.currency,
                  onTap: () {},
                  notifyParent: ({int index, dynamic value}) {
                    _bloc.add(CurrencySelected(value));
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
                  items: InvestStrategy.values.map((e) => t(e.value)).toList(),
                  selectedItem: t(state.strategy.value),
                  onTap: () {},
                  notifyParent: ({int index, dynamic value}) {
                    _bloc.add(StrategySetected(InvestStrategy.values[index]));
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
                  state.amplitude.index,
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
                    ? Container(
                        child: Column(
                          children: [
                            Input(
                              labelText: '${state.amplitude} %',
                              autovalidate: AutovalidateMode.disabled,
                              controller: _controller,
                              onChanged: (String v) {},
                              keyboardType: TextInputType.number,
                            )
                          ],
                        ),
                      )
                    : RadioGroupButton(
                        state.amplitude.index,
                        ['10%', '50%', '90%']
                            .map(
                              (v) => [
                                v,
                                () {
                                  _bloc.add(PercentageSelected(v));
                                  Log.debug(v);
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
                Spacer(),
                Container(
                  padding: EdgeInsets.only(bottom: 48),
                  margin: EdgeInsets.symmetric(horizontal: 36),
                  child: SecondaryButton(
                    t('next'),
                    () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        shape: bottomSheetShape,
                        context: context,
                        builder: (context) => Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 22.0, horizontal: 16.0),
                          child: InvestPlanPreview(),
                        ),
                      );
                    },
                    textColor: Theme.of(context).accentColor,
                    borderColor: Theme.of(context).accentColor,
                  ),
                ),
              ]),
            );
          }
        },
      ),
    );
  }
}
