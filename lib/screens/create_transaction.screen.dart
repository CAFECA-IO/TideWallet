import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './transaction_preview.screen.dart';
import '../models/transaction.model.dart';
// import '../blocs/user/user_bloc.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../widgets/appBar.dart';
import '../widgets/buttons/radio_button.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/inputs/input.dart';
import '../helpers/i18n.dart';

class CreateTransactionScreen extends StatefulWidget {
  static const routeName = '/create-transaction';

  @override
  _CreateTransactionScreenState createState() =>
      _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends State<CreateTransactionScreen> {
  TransactionBloc _bloc;
  // UserBloc _userBloc;
  final t = I18n.t;

  TextEditingController _addressController;
  TextEditingController _amountController;
  TextEditingController _gasController;
  TextEditingController _gasPriceController;
  final _form = GlobalKey<FormState>();
  bool _isSelected = false;

  @override
  void initState() {
    // TODO: implement
    _addressController = TextEditingController();
    _amountController = TextEditingController();
    _gasController = TextEditingController();
    _gasPriceController = TextEditingController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _bloc = BlocProvider.of<TransactionBloc>(context);
    // _userBloc = BlocProvider.of<UserBloc>(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.close();
    // _userBloc.close();
    _addressController.dispose();
    _amountController.dispose();
    _gasController.dispose();
    _gasPriceController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralAppbar(
        title: t('send_coin'),
        routeName: CreateTransactionScreen.routeName,
      ),
      resizeToAvoidBottomInset: false,
      body: BlocBuilder<TransactionBloc, TransactionState>(
          cubit: _bloc,
          builder: (context, state) {
            print(state.runtimeType);
            print(state.props);
            if (state is TransactionCheck)
              return Container(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                margin: EdgeInsets.symmetric(vertical: 16.0),
                child: Form(
                  key: _form,
                  child: Column(
                    children: [
                      Input(
                        onChanged: (String _) {
                          _bloc.add(ValidAddress(_addressController.text));
                        },
                        labelText: t('send_to'),
                        autovalidate: AutovalidateMode.disabled,
                        controller: _addressController,
                        suffixIcon: GestureDetector(
                            onTap: () async {},
                            child: ImageIcon(AssetImage(
                                'assets/images/icons/ic_qrcode.png'))),
                      ),
                      state.rules[0] || state.address.isEmpty
                          ? SizedBox(height: 20)
                          : Align(
                              child: Container(
                                margin: EdgeInsets.only(top: 4),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  t('invalid_address'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .copyWith(
                                          color: Theme.of(context).errorColor),
                                ),
                              ),
                              alignment: Alignment.centerLeft,
                            ),
                      SizedBox(height: 20.0),
                      Input(
                        onChanged: (String _) {
                          _bloc.add(ValidAmount(_amountController.text));
                        },
                        inputFormatter: [
                          FilteringTextInputFormatter.deny(RegExp(r"\s")),
                          FilteringTextInputFormatter.allow(
                              RegExp(r'(^\d*\.?\d*)$')),
                        ],
                        labelText: t('amount'),
                        autovalidate: AutovalidateMode.disabled,
                        controller: _amountController,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                      ),
                      state.rules[1] || state.amount.isEmpty
                          ? SizedBox(height: 20)
                          : Align(
                              child: Container(
                                margin: EdgeInsets.only(top: 4),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  t('invalid_amount'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .copyWith(
                                          color: Theme.of(context).errorColor),
                                ),
                              ),
                              alignment: Alignment.centerLeft,
                            ),
                      SizedBox(height: 12.0),
                      Container(
                        child: Align(
                          child: Text(
                            '${t('balance')}: 3930 btc',
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                          alignment: Alignment.centerRight,
                        ),
                      ),
                      SizedBox(height: 24.0),
                      Container(
                        child: Align(
                          child: Text(
                            t('transaction_fee'),
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      _isSelected
                          ? SizedBox(
                              height: 0,
                            )
                          : Column(
                              children: [
                                Container(
                                  child: Align(
                                    child: Text(
                                      '${t('processing_time')} 10 ~ 30 ${t('minute')}',
                                      style:
                                          Theme.of(context).textTheme.bodyText2,
                                    ),
                                    alignment: Alignment.centerLeft,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                              ],
                            ),
                      Container(
                        child: Align(
                          child: Text(
                            t('higher_fees_faster_transaction'),
                            style: Theme.of(context).textTheme.caption,
                          ),
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                      SizedBox(height: _isSelected ? 12 : 28.0),
                      _isSelected
                          ? Container(
                              child: Column(
                                children: [
                                  Input(
                                    inputFormatter: [
                                      FilteringTextInputFormatter.deny(
                                          RegExp(r"\s")),
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'(^\d*\.?\d*)$')),
                                    ],
                                    labelText:
                                        '${t('custom')} Gas Price (gwei)',
                                    autovalidate: AutovalidateMode.disabled,
                                    controller: _gasPriceController,
                                    onChanged: (String v) {
                                      _bloc.add(InputGasLimit(v));
                                    },
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                  ),
                                  SizedBox(height: 16.0),
                                  Input(
                                    labelText: '${t('custom')} Gas (units)',
                                    autovalidate: AutovalidateMode.disabled,
                                    controller: _gasController,
                                    onChanged: (String v) {
                                      _bloc.add(InputGasPrice(v));
                                    },
                                    keyboardType: TextInputType.number,
                                  )
                                ],
                              ),
                            )
                          : RadioGroupButton([
                              [
                                t('slow'),
                                () {
                                  _bloc.add(
                                      ChangePriority(TransactionPriority.slow));
                                }
                              ],
                              [
                                t('standard'),
                                () {
                                  _bloc.add(ChangePriority(
                                      TransactionPriority.standard));
                                }
                              ],
                              [
                                t('fast'),
                                () {
                                  _bloc.add(
                                      ChangePriority(TransactionPriority.fast));
                                }
                              ]
                            ]),
                      SizedBox(height: 28.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${t('estimated')}:  … ',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          Text(
                            '${t('balance')}: 0.0945 btc',
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        ],
                      ),
                      Spacer(),
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
                      SizedBox(height: 20.0),
                      Container(
                        padding: EdgeInsets.only(bottom: 48),
                        margin: EdgeInsets.symmetric(horizontal: 36),
                        child: SecondaryButton(
                          t('next'),
                          () {
                            if (state.rules[0] == true &&
                                state.rules[1] == true)
                              Navigator.of(context).pushNamed(
                                  TransactionPreviewScreen.routeName);
                            else
                              // TODO alertDialog
                              () {};
                          },
                          textColor: Theme.of(context).accentColor,
                          borderColor: Theme.of(context).accentColor,
                        ),
                      )
                    ],
                  ),
                ),
              );
          }),
    );
  }
}
