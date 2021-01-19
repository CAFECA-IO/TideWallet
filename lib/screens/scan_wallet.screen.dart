import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../repositories/user_repository.dart';
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
  UserRepository _repo;
  RestoreWalletBloc _bloc;

  @override
  void didChangeDependencies() {
    _repo = Provider.of<UserRepository>(context);
    _bloc = RestoreWalletBloc(_repo);

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
          showDialog(
            // barrierDismissible: false,
            barrierColor: Colors.transparent,
            context: context,
            builder: (context) => VerifyPasswordDialog(() {}, () {}),
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
