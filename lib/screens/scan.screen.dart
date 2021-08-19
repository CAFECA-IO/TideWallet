import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/scan/scan_bloc.dart';
import '../repositories/scan_repository.dart';
import 'transaction.screen.dart';
import '../screens/wallet_connect.screen.dart';
import '../widgets/appBar.dart';
import '../widgets/qrcode_view.dart';
import '../helpers/i18n.dart';

final t = I18n.t;

class ScanScreen extends StatefulWidget {
  static const routeName = '/scan';
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late ScanBloc _bloc;
  late ScanRepository _repo;

  @override
  void didChangeDependencies() {
    _repo = ScanRepository();
    _bloc = ScanBloc(_repo);

    super.didChangeDependencies();
  }

  void _scanResult(String result) {
    _bloc.add(ScanQRCode(result));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScanBloc, ScanState>(
      bloc: _bloc,
      listenWhen: (previous, current) =>
          previous != current &&
          (current is! ScannedWalletConnect || current is! ScannedAddress),
      listener: (context, state) {
        if (state is ScannedWalletConnect) {
          Navigator.of(context).pop();
          Navigator.of(context)
              .pushNamed(WalletConnectScreen.routeName, arguments: state.uri);
        } else if (state is ScannedAddress) {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(TransactionScreen.routeName,
              arguments: {"account": state.account, "address": state.address});
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        appBar: GeneralAppbar(
          routeName: ScanScreen.routeName,
          title: t('scan'),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            QRCodeView(
              scanCallback: this._scanResult,
              debugLabel: 'scan',
            ),
            BlocBuilder<ScanBloc, ScanState>(
              bloc: _bloc,
              builder: (context, state) {
                if (state is ErrorFormat)
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
                else
                  return SizedBox();
              },
            )
          ],
        ),
      ),
    );
  }
}
