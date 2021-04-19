import 'package:flutter/material.dart';

import '../widgets/appBar.dart';

class RecoverMemonicScreen extends StatefulWidget {
  static const routeName = '/recover-mnemonic';
  @override
  _RecoverMemonicScreenState createState() => _RecoverMemonicScreenState();
}

class _RecoverMemonicScreenState extends State<RecoverMemonicScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralAppbar(
        routeName: RecoverMemonicScreen.routeName,
      ),
      body: Container(),
      // body: BlocListener<RestoreWalletBloc, RestoreWalletState>(
      //   listener: (context, state) async {
      //     if (state is PaperWalletSuccess) {
      //       // Wait for Navigator back from Scan Screen
      //       await Future.delayed(Duration(milliseconds: 300));
      //       DialogController.showUnDissmissible(
      //         context,
      //         VerifyPasswordDialog((String password) {
      //           DialogController.dismiss(context);
      //           _bloc.add(RestorePapaerWallet(password));
      //         }, (String password) {
      //           _bloc.add(CleanWalletResult());
      //           DialogController.dismiss(context);
      //         }),
      //       );
      //     }

      //     if (state is PaperWalletRestored) {
      //       Navigator.of(context).popUntil(
      //         (ModalRoute.withName('/')),
      //       );
      //       _userBloc.add(UserRestore());
      //     }

      //     if (state is PaperWallletRestoring) {
      //       DialogController.showUnDissmissible(context, LoadingDialog());
      //     }

      //     if (state is PaperWalletRestoreFail) {
      //       DialogController.dismiss(context);

      //       if (state.error == RESTORE_ERROR.PASSWORD) {
      //         DialogController.show(context, ErrorDialog(t('error_password')));
      //       } else {
      //         DialogController.show(context, ErrorDialog(t('error_restore')));
      //       }
      //     }
      //   },
      //   child: Container(
      //     padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: [
      //         Container(
      //           padding: const EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 14.0),
      //           decoration: BoxDecoration(
      //             color: Color(0xFFBEEFF0),
      //           ),
      //           child: Text(
      //             t('restore_message'),
      //             style: Theme.of(context).textTheme.bodyText1,
      //           ),
      //         ),
      //         Padding(
      //           padding: const EdgeInsets.symmetric(
      //               horizontal: 36.0, vertical: 12.0),
      //           child: SecondaryButton(
      //             t('scan'),
      //             () {
      //               Navigator.of(context).pushNamed(ScanWalletScreen.routeName);
      //             },
      //             textColor: _btnColor,
      //             borderColor: _btnColor,
      //           ),
      //         )
      //       ],
      //     ),
      //   ),
      
    );
  }
}