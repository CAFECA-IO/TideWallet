import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../helpers/i18n.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../widgets/appBar.dart';
import '../widgets/buttons/secondary_button.dart';

class TransactionPreviewScreen extends StatefulWidget {
  static const routeName = '/transaction-preview';

  @override
  _TransactionPreviewScreenState createState() =>
      _TransactionPreviewScreenState();
}

class _TransactionPreviewScreenState extends State<TransactionPreviewScreen> {
  TransactionBloc _bloc;
  UserBloc _userBloc;
  final t = I18n.t;

  @override
  void didChangeDependencies() {
    _bloc = BlocProvider.of<TransactionBloc>(context);
    _userBloc = BlocProvider.of<UserBloc>(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.close();
    _userBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralAppbar(
        title: t('preview'),
        routeName: TransactionPreviewScreen.routeName,
      ),
      body: Container(
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
                    child: Text("18e044328d1687c13300fdc28a18e044328d1687c13"),
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
                    child: Text("20 btc"),
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
                    child: Text("0.000023 btc"),
                    alignment: Alignment.centerLeft,
                  ),
                  SizedBox(height: 4),
                  Align(
                    child: Text(
                      "≈ 10 USD",
                      style: Theme.of(context).textTheme.caption,
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                ],
              ),
            ),
            Spacer(),
            BlocListener<TransactionBloc, TransactionState>(
              cubit: _bloc,
              listener: (context, state) {},
              child: Container(
                padding: EdgeInsets.only(bottom: 48),
                margin: EdgeInsets.symmetric(horizontal: 36),
                child: SecondaryButton(
                  "Confirm",
                  () {
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
    );
  }
}
