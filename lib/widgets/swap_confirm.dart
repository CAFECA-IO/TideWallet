import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../blocs/verify_password/verify_password_bloc.dart';
import '../repositories/user_repository.dart';

import '../helpers/i18n.dart';
import '../theme.dart';

import 'buttons/primary_button.dart';
import 'dialogs/dialog_controller.dart';
import 'dialogs/error_dialog.dart';
import 'dialogs/verify_password_dialog.dart';

final t = I18n.t;

class SwapConfirm extends StatefulWidget {
  final Map<String, String> sellCurrency;
  final Map<String, String> buyCurrency;
  final String exchangeRate;
  final Function confirmFunc;

  SwapConfirm(
      {this.sellCurrency,
      this.buyCurrency,
      this.confirmFunc,
      this.exchangeRate});

  @override
  _SwapConfirmState createState() => _SwapConfirmState();
}

class _SwapConfirmState extends State<SwapConfirm> {
  VerifyPasswordBloc _verifyPasswordBloc;
  UserRepository _userRepo;

  @override
  void didChangeDependencies() {
    this._userRepo = Provider.of<UserRepository>(context, listen: false);
    this._verifyPasswordBloc = VerifyPasswordBloc(this._userRepo);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Widget accountItem(Map item) => Column(
          children: <Widget>[
            Image.network(
              item['icon'],
              width: 30.0,
              height: 30.0,
            ),
            SizedBox(height: 10.0),
            Text(item['amount'])
          ],
        );

    Widget detailItem(String title, String value) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(color: MyColors.primary_06),
              ),
              Text(
                value,
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
        );

    return FractionallySizedBox(
      heightFactor: 0.7,
      child: Container(
        child: Column(
          children: <Widget>[
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      Icons.close,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 20.0),
                color: Theme.of(context).primaryColor.withAlpha(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        accountItem(widget.sellCurrency),
                        Text(
                          'to',
                          style: TextStyle(color: MyColors.secondary_02),
                        ),
                        accountItem(widget.buyCurrency)
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        t('exchange_details'),
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xff000000).withOpacity(0.1),
                            blurRadius: 3,
                            spreadRadius: 1,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          detailItem(t('exchange_rate'),
                              '1${widget.sellCurrency['symbol']} = ${widget.exchangeRate} ${widget.buyCurrency['symbol']}'),
                          detailItem(t('buy'),
                              '${widget.buyCurrency['amount']} ${widget.buyCurrency['symbol']}'),
                          detailItem(t('sell'),
                              '${widget.sellCurrency['amount']} ${widget.sellCurrency['symbol']}')
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ++ add verifyPassword BLOC 2021/3/17 Emily
            BlocListener<VerifyPasswordBloc, VerifyPasswordState>(
              cubit: _verifyPasswordBloc,
              listener: (context, state) {
                if (state is PasswordVerified) {
                  widget.confirmFunc();
                  Navigator.of(context).pop();
                }
                if (state is PasswordInvalid) {
                  DialogController.show(
                      context, ErrorDialog(t('error_password')));
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 16.0),
                width: double.infinity,
                child: PrimaryButton('Confirm', () {
                  DialogController.showUnDissmissible(
                    context,
                    VerifyPasswordDialog((String password) {
                      _verifyPasswordBloc.add(VerifyPassword(password));
                      DialogController.dismiss(context);
                    }, (String password) {
                      DialogController.dismiss(context);
                    }),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
