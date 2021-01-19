import 'package:flutter/material.dart';
import 'package:tidewallet3/theme.dart';
// import 'package:barcode_scan/barcode_scan.dart';

import '../blocs/create_transaction/create_transaction_bloc.dart';
import './transaction_preview.screen.dart';
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
  CreateTransactionBloc _bloc;
  final t = I18n.t;

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _isSelected = false;
  double _currentSliderValue = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralAppbar(
        title: t('send_coin'),
        routeName: CreateTransactionScreen.routeName,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        margin: EdgeInsets.symmetric(vertical: 16.0),
        child: Form(
          key: _form,
          child: Column(
            children: [
              Input(
                labelText: t('send_to'),
                autovalidate: AutovalidateMode.disabled,
                controller: _addressController,
                onChanged: (String v) {
                  // _bloc.add(InputWalletName(v));
                },
                suffixIcon: GestureDetector(
                    onTap: () async {
                      // ScanResult result = await BarcodeScanner.scan();
                      // if (result != null) {
                      //   _addressController.text = result.rawContent;
                      //   // _bloc
                      //   //     .add(CheckAddressValidity(_addressController.text));
                      //   Navigator.of(context).pop();
                      // }
                    },
                    child: ImageIcon(
                        AssetImage('assets/images/icons/ic_qrcode.png'))),
              ),
              SizedBox(height: 12.0),
              Input(
                labelText: t('amount'),
                autovalidate: AutovalidateMode.disabled,
                controller: _amountController,
                onChanged: (String v) {
                  // _bloc.add(InputWalletName(v));
                },
              ),
              SizedBox(height: 8.0),
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
                              style: Theme.of(context).textTheme.bodyText2,
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
              SizedBox(height: 28.0),
              _isSelected
                  ? Container(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                t('slow'),
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                              Text(
                                t('fast'),
                                style: Theme.of(context).textTheme.bodyText2,
                              )
                            ],
                          ),
                          Slider(
                            activeColor: MyColors.primary_02,
                            inactiveColor: MyColors.secondary_03,
                            value: _currentSliderValue,
                            min: 0,
                            max: 100,
                            divisions: 100,
                            label: _currentSliderValue.round().toString(),
                            onChanged: (double value) {
                              setState(() {
                                _currentSliderValue = value;
                              });
                            },
                          ),
                        ],
                      ),
                    )
                  : RadioGroupButton([
                      [t('slow'), () {}],
                      [t('standard'), () {}],
                      [t('fast'), () {}]
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
              SizedBox(height: 55.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    t('advanced_settings'),
                    style: Theme.of(context).textTheme.caption,
                  ),
                  SizedBox(width: 12),
                  Switch(
                    value: _isSelected,
                    onChanged: (bool newValue) {
                      setState(() {
                        _isSelected = newValue;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 28.0),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 36),
                child: SecondaryButton(
                  t('next'),
                  () {
                    Navigator.of(context)
                        .pushNamed(TransactionPreviewScreen.routeName);
                  },
                  textColor: MyColors.primary_03,
                  borderColor: MyColors.primary_03,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
