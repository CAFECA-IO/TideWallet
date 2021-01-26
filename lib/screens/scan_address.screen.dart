import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/transaction/transaction_bloc.dart';
import '../widgets/appBar.dart';
import '../widgets/qrcode_view.dart';
import '../helpers/i18n.dart';

final t = I18n.t;

class ScanAddressScreen extends StatefulWidget {
  static const routeName = '/scan-wallet';
  @override
  _ScanAddressScreenState createState() => _ScanAddressScreenState();
}

class _ScanAddressScreenState extends State<ScanAddressScreen> {
  TransactionBloc _bloc;

  @override
  void didChangeDependencies() {
    _bloc = BlocProvider.of<TransactionBloc>(context);

    super.didChangeDependencies();
  }

  void _scanResult(String result) {
    _bloc.add(ScanQRCode(result));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
      cubit: _bloc,
      listener: (context, state) {
        if (state is TransactionInitial && state.rules[0]) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: GeneralAppbar(
          routeName: ScanAddressScreen.routeName,
          title: t('scan_title'),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            QRCodeView(
              scanCallback: this._scanResult,
            ),
            BlocBuilder<TransactionBloc, TransactionState>(
              cubit: _bloc,
              builder: (context, state) {
                if (state is TransactionInitial && !state.rules[0]) {
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
