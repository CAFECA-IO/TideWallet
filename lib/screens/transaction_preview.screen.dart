import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import './transaction_list.screen.dart';
import '../models/transaction.model.dart';
import '../models/account.model.dart';
import '../repositories/user_repository.dart';
import '../blocs/verify_password/verify_password_bloc.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../widgets/appBar.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/dialogs/error_dialog.dart';
import '../widgets/dialogs/loading_dialog.dart';
import '../widgets/dialogs/dialog_controller.dart';
import '../widgets/dialogs/verify_password_dialog.dart';
import '../helpers/i18n.dart';

class TransactionPreviewScreen extends StatefulWidget {
  static const routeName = '/transaction-preview';

  @override
  _TransactionPreviewScreenState createState() =>
      _TransactionPreviewScreenState();
}

class _TransactionPreviewScreenState extends State<TransactionPreviewScreen> {
  TransactionBloc _bloc;
  VerifyPasswordBloc _verifyPasswordBloc;
  Currency _currency;
  Transaction _transaction;
  String _feeToFiat;
  UserRepository _userRepo;
  final t = I18n.t;

  @override
  void didChangeDependencies() {
    Map<String, dynamic> arg = ModalRoute.of(context).settings.arguments;
    _currency = arg["currency"];
    _transaction = arg["transaction"];
    _feeToFiat = arg["feeToFiat"];

    _bloc = BlocProvider.of<TransactionBloc>(context);
    _userRepo = Provider.of<UserRepository>(context, listen: false);
    _verifyPasswordBloc = VerifyPasswordBloc(_userRepo);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
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
          if (state is CreateTransactionFail) {
            DialogController.dismiss(context);
            DialogController.show(
                context, ErrorDialog('Something went wrong...'));
            // TODO
          }
          if (state is TransactionPublishing) {
            DialogController.showUnDissmissible(context, LoadingDialog());
          }
          if (state is TransactionSent) {
            DialogController.dismiss(context);
            await Future(() {
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
                      child: Text(
                          "${_transaction.fee} ${_currency.accountSymbol}"),
                      alignment: Alignment.centerLeft,
                    ),
                    SizedBox(height: 4),
                    Align(
                      child: Text(
                        "≈ $_feeToFiat",
                        style: Theme.of(context).textTheme.caption,
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                  ],
                ),
              ),
              Spacer(),
              BlocListener<VerifyPasswordBloc, VerifyPasswordState>(
                cubit: _verifyPasswordBloc,
                listener: (context, state) {
                  if (state is PasswordVerified) {
                    _bloc.add(PublishTransaction(state.password));
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
                          _verifyPasswordBloc.add(VerifyPassword(password));
                          DialogController.dismiss(context);
                        }, (String password) {
                          DialogController.dismiss(context);
                        }),
                      );
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
