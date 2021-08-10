import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart' as lib;

import '../repositories/third_party_sign_in_repository.dart';
import '../blocs/third_party_sign_in/third_party_sign_in_bloc.dart';
import '../blocs/user/user_bloc.dart';
import '../widgets/version.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/dialogs/dialog_controller.dart';
import '../widgets/dialogs/error_dialog.dart';
import '../widgets/dialogs/loading_dialog.dart';
import '../screens/recover_mnemonic.screen.dart';
import '../helpers/logger.dart';
import '../helpers/i18n.dart';

class WelcomeScreen extends StatefulWidget {
  static const routeName = '/landing';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final t = I18n.t;
  ThirdPartySignInBloc _bloc =
      ThirdPartySignInBloc(ThirdPartySignInRepository());

  late UserBloc _userBloc;

  @override
  void didChangeDependencies() {
    _userBloc = BlocProvider.of<UserBloc>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ThirdPartySignInBloc, ThirdPartySignInState>(
      bloc: this._bloc,
      listener: (context, state) {
        Log.debug(state);
        if (state is FailedSignInWithThirdParty) {
          if (Platform.isAndroid) Navigator.of(context).pop();
          DialogController.show(
              context,
              ErrorDialog(
                  state.message != null ? t(state.message!) : t('cancel')));
        }
        if (state is CancelledSignInWithThirdParty) {
          // Navigator.of(context).pop();
          Navigator.of(context).popUntil(
            (ModalRoute.withName('/')),
          );
          DialogController.show(context, ErrorDialog(t('cancel')));
        }
        if (state is SignedInWithThirdParty) {
          if (Platform.isAndroid) Navigator.of(context).pop();
          _userBloc.add(UserCreate(state.userIndentifier));
        }
        if (state is SigningInWithThirdParty) {
          DialogController.showUnDissmissible(context, LoadingDialog());
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/welcome_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          padding: EdgeInsets.fromLTRB(52.0, 100.0, 52.0, 60.0),
          height: double.infinity,
          child: Column(
            children: [
              Image.asset(
                'assets/images/logo_type.png',
                width: 107.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: Version(
                  fontSize: 18.0,
                  color: Colors.white70,
                ),
              ),
              Spacer(),
              Platform.isIOS
                  ? lib.SignInWithAppleButton(
                      onPressed: () {
                        this._bloc.add(SignInWithApple());
                      },
                    )
                  : PrimaryButton(t('sign_in_with_google_id'), () {
                      this._bloc.add(SignInWithGoogle());
                    },
                      icon: Row(
                        children: [
                          Center(
                            child: Image(
                              image: AssetImage(
                                "assets/graphics/google-logo.png",
                              ),
                              height: 18.0,
                              width: 18.0,
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          )
                        ],
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 32.5, vertical: 8.0)),
              Container(
                margin: const EdgeInsets.only(top: 30.0),
                child: PrimaryButton(t('recover_mnemonic'), () {
                  Navigator.of(context)
                      .pushNamed(RecoverMemonicScreen.routeName);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
