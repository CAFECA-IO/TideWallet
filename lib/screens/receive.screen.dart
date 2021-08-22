import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tidewallet3/repositories/transaction_repository.dart';

import '../theme.dart';
import '../models/account.model.dart';
import '../widgets/appBar.dart';
import '../widgets/dialogs/dialog_controller.dart';
import '../widgets/dialogs/loading_dialog.dart';
import '../widgets/buttons/secondary_button.dart';
import '../helpers/i18n.dart';

import '../blocs/receive/receive_bloc.dart';
import '../constants/account_config.dart';

class ReceiveScreen extends StatefulWidget {
  static const routeName = '/receive';
  @override
  _ReceiveScreenState createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final t = I18n.t;

  late ReceiveBloc _bloc;

  Account? _account;
  String? _address;
  bool _inInit = false;

  @override
  void didChangeDependencies() {
    Map<String, Account> arg =
        ModalRoute.of(context)!.settings.arguments as Map<String, Account>;
    _account = arg["account"];
    if (!_inInit) {
      _bloc = ReceiveBloc(Provider.of<TransactionRepository>(context))
        ..add(GetReceivingAddress(_account!));
      _inInit = true;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: GeneralAppbar(
        title: t('my_wallet'),
        routeName: ReceiveScreen.routeName,
      ),
      body: BlocListener<ReceiveBloc, ReceiveState>(
          bloc: _bloc,
          listener: (context, state) {
            if (state is AddressLoading) {
              DialogController.showUnDissmissible(context, LoadingDialog());
            }
            if (state is AddressLoaded) {
              DialogController.dismiss(context);
              setState(() {
                _address = state.address;
              });
            }
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16.0),
            margin: EdgeInsets.symmetric(vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: Text(
                    '${t('remit')} ${_account!.symbol.toUpperCase()}',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 40,
                  child: Text(
                    _account!.accountType == ACCOUNT.BTC
                        ? t('btc_receving_address_hint')
                        : '',
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  child: QrImage(
                    data: _address != null ? _address! : t('dialog_loading'),
                    version: QrVersions.auto,
                    size: width * 0.7,
                  ),
                ),
                Spacer(),
                Container(
                  height: 60,
                  margin: EdgeInsets.symmetric(
                      horizontal: width * 0.035, vertical: 20),
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  color: MyColors.secondary_11,
                  child: Center(
                      child: Text(
                          _address != null ? _address! : t('dialog_loading'))),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: width * 0.1),
                  child: SecondaryButton(
                    t('copy_wallet_address'),
                    () {
                      final snackBar = SnackBar(
                        content: Text(t('copied')),
                        duration: Duration(milliseconds: 1000),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      Clipboard.setData(ClipboardData(text: _address));
                    },
                    textColor: Theme.of(context).accentColor,
                    borderColor: Theme.of(context).accentColor,
                  ),
                )
              ],
            ),
          )),
    );
  }
}
