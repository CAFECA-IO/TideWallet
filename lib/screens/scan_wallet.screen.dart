import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tidewallet3/helpers/logger.dart';

import '../blocs/restore_wallet/restore_wallet_bloc.dart';
import '../widgets/appBar.dart';
import '../widgets/qrcode_view.dart';
import '../helpers/i18n.dart';

final t = I18n.t;

class ScanWalletScreen extends StatefulWidget {
  static const routeName = '/scan-wallet';
  @override
  _ScanWalletScreenState createState() => _ScanWalletScreenState();
}

class _ScanWalletScreenState extends State<ScanWalletScreen> {
  RestoreWalletBloc _bloc;

  @override
  void didChangeDependencies() {
    _bloc = BlocProvider.of<RestoreWalletBloc>(context)
      ..add(CleanWalletResult());

    super.didChangeDependencies();
  }

  void _scanResult(String result) {
    _bloc.add(GetPaperWallet(result));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RestoreWalletBloc, RestoreWalletState>(
      bloc: _bloc,
      listener: (context, state) {
        if (state is PaperWalletSuccess) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: GeneralAppbar(
          routeName: ScanWalletScreen.routeName,
          title: t('scan_title'),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            QRCodeView(
              scanCallback: this._scanResult,
              debugLabel: 'scan_wallet',
            ),
            BlocBuilder<RestoreWalletBloc, RestoreWalletState>(
              bloc: _bloc,
              builder: (context, state) {
                if (state is PaperWalletFail) {
                  return Positioned(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 40.0),
                      child: Text(
                        t('error_format'),
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
