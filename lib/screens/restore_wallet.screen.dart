import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/restore_wallet/restore_wallet_bloc.dart';
import '../blocs/user/user_bloc.dart';
import './scan_wallet.screen.dart';
import '../widgets/dialogs/error_dialog.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/dialogs/dialog_controller.dart';
import '../widgets/dialogs/loading_dialog.dart';
import '../widgets/appBar.dart';
import '../widgets/dialogs/verify_password_dialog.dart';
import '../helpers/i18n.dart';

final t = I18n.t;

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
        listener: (context, state) async {
          if (state is PaperWalletSuccess) {
            // Wait for Navigator back from Scan Screen
            await Future.delayed(Duration(milliseconds: 300));
            DialogController.showUnDissmissible(
              context,
              VerifyPasswordDialog((String password) {
                DialogController.dismiss(context);
                _bloc.add(RestorePapaerWallet(password));
              }, (String password) {
                _bloc.add(CleanWalletResult());
                DialogController.dismiss(context);
              }),
            );
          }

          if (state is PaperWalletRestored) {
            Navigator.of(context).popUntil(
              (ModalRoute.withName('/')),
            );
            _userBloc.add(UserRestore());
          }

          if (state is PaperWallletRestoring) {
            DialogController.showUnDissmissible(context, LoadingDialog());
          }

          if (state is PaperWalletRestoreFail) {
            DialogController.dismiss(context);

            DialogController.show(context, ErrorDialog(t('error_password')));
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
                  t('restore_message'),
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 36.0, vertical: 12.0),
                child: SecondaryButton(
                  t('scan'),
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
