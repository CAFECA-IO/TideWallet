import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';

import '../blocs/create_transaction/create_transaction_bloc.dart';
import './transaction_preview.screen.dart';
import '../widgets/appBar.dart';
import '../widgets/buttons/radio_button.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/inputs/input.dart';

class CreateTransactionScreen extends StatefulWidget {
  static const routeName = '/create-transaction';

  @override
  _CreateTransactionScreenState createState() =>
      _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends State<CreateTransactionScreen> {
  CreateTransactionBloc _bloc;

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralAppbar(
        title: "Send Coin",
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
                labelText: 'Send to',
                autovalidate: AutovalidateMode.disabled,
                controller: _addressController,
                onChanged: (String v) {
                  // _bloc.add(InputWalletName(v));
                },
                suffixIcon: GestureDetector(
                    onTap: () async {
                      ScanResult result = await BarcodeScanner.scan();
                      if (result != null) {
                        _addressController.text = result.rawContent;
                        // _bloc
                        //     .add(CheckAddressValidity(_addressController.text));
                        Navigator.of(context).pop();
                      }
                    },
                    child: ImageIcon(
                        AssetImage('assets/images/icons/ic_qrcode.png'))),
              ),
              SizedBox(height: 12.0),
              Input(
                labelText: 'Amount',
                autovalidate: AutovalidateMode.disabled,
                controller: _amountController,
                onChanged: (String v) {
                  // _bloc.add(InputWalletName(v));
                },
              ),
              SizedBox(height: 8.0),
              Container(
                child: Align(
                  child: Text('Balance: 3930 btc'),
                  alignment: Alignment.centerRight,
                ),
              ),
              SizedBox(height: 24.0),
              Container(
                child: Align(
                  child: Text('Transaction Fee'),
                  alignment: Alignment.centerLeft,
                ),
              ),
              SizedBox(height: 8.0),
              Container(
                child: Align(
                  child: Text('Processing time 10 ~ 30 minute'),
                  alignment: Alignment.centerLeft,
                ),
              ),
              SizedBox(height: 8.0),
              Container(
                child: Align(
                  child: Text('Higher fees, faster transaction'),
                  alignment: Alignment.centerLeft,
                ),
              ),
              SizedBox(height: 28.0),
              RadioButton(),
              SizedBox(height: 28.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Estimated:  … '),
                  Text('Balance: 0.0945 btc'),
                ],
              ),
              SizedBox(height: 55.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Advanced Settings"),
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
              SecondaryButton("Next", () {
                Navigator.of(context)
                    .pushNamed(TransactionPreviewScreen.routeName);
              })
            ],
          ),
        ),
      ),
    );
  }
}
