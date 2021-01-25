import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../theme.dart';
import '../models/account.model.dart';
import '../widgets/appBar.dart';
import '../widgets/dialogs/dialog_controller.dart';
import '../widgets/dialogs/loading_dialog.dart';
import '../widgets/buttons/secondary_button.dart';
import '../helpers/i18n.dart';
import '../repositories/account_repository.dart';
import '../blocs/receive/receive_bloc.dart';
import '../constants/account_config.dart';

class ReceiveScreen extends StatefulWidget {
  static const routeName = '/receive';
  @override
  _ReceiveScreenState createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final t = I18n.t;
  AccountRepository _repo;
  ReceiveBloc _bloc;
  Currency _currency;
  String _address = '';
  bool _isCalled = false;

  @override
  void didChangeDependencies() {
    Map<String, Currency> arg = ModalRoute.of(context).settings.arguments;
    _currency = arg["currency"];
    _repo = Provider.of<AccountRepository>(context);
    print("_address: $_address");
    if (!_isCalled) {
      _bloc = ReceiveBloc(_repo)..add(GetReceivingAddress(_currency));
      _isCalled = true;
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
    return Scaffold(
      appBar: GeneralAppbar(
        title: t('my_wallet'),
        routeName: ReceiveScreen.routeName,
      ),
      body: BlocListener<ReceiveBloc, ReceiveState>(
          cubit: _bloc,
          listener: (context, state) {
            print('state: $state');
            if (state is AddressLoading) {
              DialogContorller.showUnDissmissible(context, LoadingDialog());
            }
            if (state is AddressLoaded) {
              DialogContorller.dismiss(context);
              setState(() {
                _address = state.address;
                print('_address: $_address');
              });
            }
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16.0),
            margin: EdgeInsets.symmetric(vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${t('remit')} ${_currency.symbol.toUpperCase()}',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                _currency.accountType == ACCOUNT.BTC
                    ? Container(
                        height: 32,
                        child: Text(
                          t('btc_receving_address_hint'),
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                      )
                    : SizedBox(height: 100),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 28),
                  child: QrImage(
                    data: _address,
                    version: QrVersions.auto,
                    size: 240.0,
                  ),
                ),
                Spacer(),
                Container(
                  height: 54,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  color: MyColors.secondary_11,
                  child: Center(child: Text(_address)),
                ),
                SizedBox(
                  height: 60,
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 48),
                  margin: EdgeInsets.symmetric(horizontal: 36),
                  child: SecondaryButton(
                    t('copy_wallet_address'),
                    () {
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
