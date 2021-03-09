import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tidewallet3/widgets/buttons/primary_button.dart';
import 'package:tidewallet3/widgets/buttons/secondary_button.dart';

import '../blocs/walletconnect/walletconnect_bloc.dart';
import '../widgets/appBar.dart';
import '../widgets/qrcode_view.dart';

class WalletConnectScreen extends StatefulWidget {
  static const routeName = '/wallet-connect';

  @override
  _WalletConnectScreenState createState() => _WalletConnectScreenState();
}

class _WalletConnectScreenState extends State<WalletConnectScreen> {
  WalletConnectBloc _bloc = WalletConnectBloc();

  _scanResult(String v) {
    _bloc.add(ScanWC(v));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletConnectBloc, WalletConnectState>(
      cubit: _bloc,
      builder: (context, state) {
        if (state is WalletConnectInitial) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: GeneralAppbar(
              routeName: WalletConnectScreen.routeName,
            ),
            body: Stack(
              alignment: Alignment.center,
              children: [
                QRCodeView(
                  scanCallback: this._scanResult,
                ),
              ],
            ),
          );
        }

        if (state is WalletConnectConnecting) {
          return Scaffold(
              body: Container(child: Center(child: Text('Loading....'))));
        }

        return Scaffold(
          appBar: GeneralAppbar(
            routeName: WalletConnectScreen.routeName,
          ),
          body: Container(
            child: Column(
              children: [
                PrimaryButton('Approve', () {
                  _bloc.add(ApproveWC());
                }),
                SecondaryButton('Disconnect', () {
                  _bloc.add(DisconnectWC(''));
                })
              ],
            ),
          ),
        );
      },
    );
  }
}
