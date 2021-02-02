import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './transaction_list.screen.dart';
import '../models/transaction.model.dart';
import '../models/account.model.dart';
import '../helpers/i18n.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../widgets/appBar.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/dialogs/error_dialog.dart';
import '../widgets/dialogs/loading_dialog.dart';
import '../widgets/dialogs/dialog_controller.dart';
import '../widgets/dialogs/verify_password_dialog.dart';

class TransactionPreviewScreen extends StatefulWidget {
  static const routeName = '/transaction-preview';

  @override
  _TransactionPreviewScreenState createState() =>
      _TransactionPreviewScreenState();
}

class _TransactionPreviewScreenState extends State<TransactionPreviewScreen> {
  TransactionBloc _bloc;
  UserBloc _userBloc;
  Currency _currency;
  Transaction _transaction;
  final t = I18n.t;

  @override
  void didChangeDependencies() {
    Map<String, dynamic> arg = ModalRoute.of(context).settings.arguments;
    _currency = arg["currency"];
    _transaction = arg["transaction"];
    _bloc = BlocProvider.of<TransactionBloc>(context);
    _userBloc = BlocProvider.of<UserBloc>(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    // _bloc.close();
    _userBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralAppbar(
        title: t('preview'),
        routeName: TransactionPreviewScreen.routeName,
      ),
      body: BlocListener<TransactionBloc, TransactionState>(
        cubit: _bloc,
        listener: (context, state) async {
          print(state);
          if (state is TransactionPublishing) {
            DialogController.showUnDissmissible(context, LoadingDialog());
          }
          if (state is TransactionSent) {
            DialogController.dismiss(context);
            await Future.delayed(Duration(milliseconds: 150), () {
              Navigator.of(context).popUntil((route) =>
                  route.settings.name == TransactionListScreen.routeName);
            });
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          margin: EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              Container(
                child: Column(
                  children: [
                    Align(
                      child: Text(
                        t('to'),
                        style: Theme.of(context).textTheme.caption,
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                    SizedBox(height: 7),
                    Align(
                      child: Text(_transaction.address),
                      alignment: Alignment.centerLeft,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Column(
                  children: [
                    Align(
                      child: Text(
                        t('amount'),
                        style: Theme.of(context).textTheme.caption,
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                    SizedBox(height: 7),
                    Align(
                      child: Text("${_transaction.amount} ${_currency.symbol}"),
                      alignment: Alignment.centerLeft,
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Column(
                  children: [
                    Align(
                      child: Text(
                        t('transaction_fee'),
                        style: Theme.of(context).textTheme.caption,
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                    SizedBox(height: 7),
                    Align(
                      child: Text("${_transaction.fee} ${_currency.symbol}"),
                      alignment: Alignment.centerLeft,
                    ),
                    SizedBox(height: 4),
                    Align(
                      child: Text(
                        "≈ 10 USD", // TODO
                        style: Theme.of(context).textTheme.caption,
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                  ],
                ),
              ),
              Spacer(),
              BlocListener<UserBloc, UserState>(
                cubit: _userBloc,
                listener: (context, state) {
                  if (state is PasswordVerified) {
                    _bloc.add(CreateTransaction());
                  }
                  if (state is PasswordInvalid) {
                    DialogController.show(
                        context, ErrorDialog(t('error_password')));
                  }
                },
                child: Container(
                  padding: EdgeInsets.only(bottom: 48),
                  margin: EdgeInsets.symmetric(horizontal: 36),
                  child: SecondaryButton(
                    "Confirm",
                    () {
                      DialogController.showUnDissmissible(
                        context,
                        VerifyPasswordDialog((String password) {
                          _userBloc.add(VerifyPassword(password));
                          DialogController.dismiss(context);
                        }, (String password) {
                          DialogController.dismiss(context);
                        }),
                      );

                      print(_bloc.state.props);
                    },
                    textColor: Theme.of(context).accentColor,
                    borderColor: Theme.of(context).accentColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
