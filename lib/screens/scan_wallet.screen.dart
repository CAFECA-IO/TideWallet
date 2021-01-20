import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/restore_wallet/restore_wallet_bloc.dart';
import '../widgets/dialogs/verify_password_dialog.dart';
import '../widgets/appBar.dart';
import '../widgets/qrcode_view.dart';

class ScanWalletScreen extends StatefulWidget {
  static const routeName = '/scan-wallet';
  @override
  _ScanWalletScreenState createState() => _ScanWalletScreenState();
}

class _ScanWalletScreenState extends State<ScanWalletScreen> {
  RestoreWalletBloc _bloc;

  @override
  void didChangeDependencies() {
    _bloc = BlocProvider.of<RestoreWalletBloc>(context);

    super.didChangeDependencies();
  }

  void _scanResult(String result) {
    _bloc.add(GetPaperWallet(result));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RestoreWalletBloc, RestoreWalletState>(
      cubit: _bloc,
      listener: (context, state) {

        if (state is PaperWalletSuccess) {
          Navigator.of(context).pop();
          showDialog(
            barrierDismissible: false,
            barrierColor: Colors.transparent,
            context: context,
            builder: (context) => VerifyPasswordDialog((String password) {
              _bloc.add(RestorePapaerWallet(password));
            }, (String password) {
              _bloc.add(CleanWalletResult());
              Navigator.of(context).pop();
            }),
          );
        }

      
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: GeneralAppbar(
          routeName: ScanWalletScreen.routeName,
          title: 'Scan your Keystore',
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            QRCodeView(
              scanCallback: this._scanResult,
            ),
            BlocBuilder<RestoreWalletBloc, RestoreWalletState>(
              cubit: _bloc,
              builder: (context, state) {
                if (state is PaperWalletFail) {
                  return Positioned(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 40.0),
                      child: Text(
                        '格式錯誤',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ),
                    bottom: 100.0,
                  );
                } else {
                  return SizedBox();
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
