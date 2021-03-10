import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/walletconnect/walletconnect_bloc.dart';
import '../helpers/formatter.dart';
import '../theme.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/walletconnect/sign_transaction.dart';
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
    return BlocListener<WalletConnectBloc, WalletConnectState>(
      listener: (context, state) {
        if (state is WalletConnectLoaded) {
          if (state.status == WC_STATUS.WAITING) {
            showModalBottomSheet(
              isDismissible: false,
              context: context,
              shape: bottomSheetShape,
              builder: (context) => Container(
                padding: EdgeInsets.symmetric(vertical: 22.0, horizontal: 16.0),
                child: Container(
                  height: 140,
                  child: Column(
                    children: [
                      PrimaryButton('連接', () {
                        _bloc.add(ApproveWC());
                        Navigator.of(context).pop();
                      }),
                      SizedBox(height: 20.0),
                      SecondaryButton(
                        '取消',
                        () {
                          _bloc.add(DisconnectWC(''));
                          Navigator.of(context).popUntil(
                            (ModalRoute.withName('/')),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
            );
          }

          if (state.currentEvent != null) {
            Widget content;
            bool isScrollControlled = false;

            switch (state.currentEvent.method) {
              case 'eth_sendTransaction':
                content = SignTransaction(
                    context, state.peer.url, state.currentEvent.params[0]);
                isScrollControlled = true;
                break;

              default:
            }

            if (content == null) return;

            showModalBottomSheet(
                isDismissible: false,
                context: context,
                isScrollControlled: isScrollControlled,
                shape: bottomSheetShape,
                builder: (context) => content);
          }
        }
      },
      cubit: _bloc,
      child: Scaffold(
        appBar: GeneralAppbar(
          title: 'TideWallet Connect',
          routeName: WalletConnectScreen.routeName,
          leadingFunc: () {
            _bloc.add(DisconnectWC(''));
            Navigator.of(context).pop();
          },
        ),
        body: BlocBuilder<WalletConnectBloc, WalletConnectState>(
          cubit: _bloc,
          builder: (context, state) {
            if (state is WalletConnectInitial) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  QRCodeView(
                    scanCallback: this._scanResult,
                  ),
                ],
              );
            }

            if (state is WalletConnectLoaded) {
              Widget status;
              TextStyle style = Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(fontSize: 16.0);

              if (state.status == WC_STATUS.CONNECTED ||
                  state.status == WC_STATUS.WAITING) {
                status = Text(
                  '在線',
                  style: style.copyWith(color: Colors.green),
                );
              } else {
                status = Text(
                  '離線',
                  style: style.copyWith(color: Colors.redAccent),
                );
              }

              if (state.peer == null && state.status == WC_STATUS.CONNECTING) {
                return Center(
                    child: Text(
                  'Loading...',
                  style: style,
                ));
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    children: [
                      Container(
                        child: Column(
                          children: [
                            state.peer.icons.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Image.network(
                                      state.peer.icons[0],
                                      width: 60.0,
                                      height: 60.0,
                                    ),
                                  )
                                : SizedBox(),
                            Text(
                              state.peer.name,
                              style: Theme.of(context).textTheme.headline1,
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 40.0),
                      StatusItem('狀態', status),
                      StatusItem(
                        '已連線到',
                        Text(
                          state.peer.url.replaceAll('https://', ''),
                          style: style,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      StatusItem(
                        '地址',
                        Text(
                          Formatter.formatAdddress(state.accounts[0],
                              showLength: 14),
                          style: style,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      StatusItem(
                        '已簽署交易',
                        InkWell(
                          child: Image.asset(
                              'assets/images/icons/ic_arrow_right_normal.png'),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class StatusItem extends StatelessWidget {
  final String _title;
  final Widget _value;

  StatusItem(this._title, this._value);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.0, color: Theme.of(context).cursorColor),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _title,
            style:
                Theme.of(context).textTheme.headline1.copyWith(fontSize: 17.0),
          ),
          SizedBox(
            width: 4.0,
          ),
          Flexible(
            child: _value,
          ),
        ],
      ),
    );
  }
}
