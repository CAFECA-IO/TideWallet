import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tidewallet3/widgets/appBar.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '../blocs/restore_wallet/restore_wallet_bloc.dart';
import '../blocs/user/user_bloc.dart';
import './scan_wallet.screen.dart';
import '../widgets/dialogs/error_dialog.dart';
import '../widgets/buttons/secondary_button.dart';

class RestoreWalletScreen extends StatefulWidget {
  static const routeName = '/restore-wallet';

  @override
  _RestoreWalletScreenState createState() => _RestoreWalletScreenState();
}

class _RestoreWalletScreenState extends State<RestoreWalletScreen> {
  RestoreWalletBloc _bloc;
  UserBloc _userBloc;

  void didChangeDependencies() {
    _bloc = BlocProvider.of<RestoreWalletBloc>(context);
    _userBloc = BlocProvider.of<UserBloc>(context);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final _btnColor = Theme.of(context).accentColor;
    return Scaffold(
      appBar: GeneralAppbar(
        routeName: RestoreWalletScreen.routeName,
      ),
      body: BlocListener<RestoreWalletBloc, RestoreWalletState>(
        listener: (context, state) {
          if (state is PaperWalletRestored) {
            Navigator.of(context).popUntil(
              (ModalRoute.withName('/')),
            );
            _userBloc.add(UserRestore());
          }

          if (state is PaperWalletRestoreFail) {
            Navigator.of(context).pop();
            showDialog(context: context, child: ErrorDialog('密碼錯誤'), barrierColor: Colors.transparent);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 14.0),
                decoration: BoxDecoration(
                  color: Color(0xFFBEEFF0),
                ),
                child: Text(
                  'Ethereum’s official wallet uses keystore format to store encrypted private key information, you can copy and paste the content into the input field, or with the help of QR code generate.',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 36.0, vertical: 12.0),
                child: SecondaryButton(
                  '掃描',
                  () {
                    Navigator.of(context).pushNamed(ScanWalletScreen.routeName);
                  },
                  textColor: _btnColor,
                  borderColor: _btnColor,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
