import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import './transaction_list.screen.dart';
import '../models/transaction.model.dart';
import '../models/account.model.dart';
import '../repositories/user_repository.dart';
import '../repositories/local_auth_repository.dart';
import '../blocs/local_auth/local_auth_bloc.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../widgets/appBar.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/dialogs/error_dialog.dart';
import '../widgets/dialogs/loading_dialog.dart';
import '../widgets/dialogs/dialog_controller.dart';
import '../helpers/i18n.dart';

class TransactionPreviewScreen extends StatefulWidget {
  static const routeName = '/transaction-preview';

  @override
  _TransactionPreviewScreenState createState() =>
      _TransactionPreviewScreenState();
}

class _TransactionPreviewScreenState extends State<TransactionPreviewScreen> {
  late TransactionBloc _bloc;
  late LocalAuthBloc _localBloc;
  late Account _account;
  late Transaction _transaction;
  late String _feeToFiat;
  late UserRepository _userRepo;
  final t = I18n.t;

  @override
  void didChangeDependencies() {
    Map<String, dynamic> arg =
        ModalRoute.of(context)!.settings.arguments! as Map<String, dynamic>;
    _account = arg["account"];
    _transaction = arg["transaction"];
    _feeToFiat = arg["feeToFiat"];

    _bloc = BlocProvider.of<TransactionBloc>(context);
    _userRepo = Provider.of<UserRepository>(context, listen: false);
    _localBloc = LocalAuthBloc(LocalAuthRepository());
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
        bloc: _bloc,
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
                      child: Text("${_transaction.amount} ${_account.symbol}"),
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
                          "${_transaction.fee} ${_account.shareAccountSymbol}"),
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
              BlocListener<LocalAuthBloc, LocalAuthState>(
                bloc: _localBloc,
                listener: (context, state) {
                  if (state is AuthenticationStatus) {
                    if (!state.isAuthenicated) {
                      // ++ [Emily 4/1/2021]
                      DialogController.dismiss(context);
                      DialogController.show(
                          context, ErrorDialog('Authentication Fail'));
                    }
                  }
                },
                child: Container(
                  padding: EdgeInsets.only(bottom: 48),
                  margin: EdgeInsets.symmetric(horizontal: 36),
                  child: SecondaryButton(
                    "Confirm",
                    () {
                      this._localBloc.add(Authenticate());
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
