import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart' as lib;

import '../repositories/third_party_sign_in_repository.dart';
import '../blocs/third_party_sign_in/third_party_sign_in_bloc.dart';
import '../blocs/user/user_bloc.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/dialogs/dialog_controller.dart';
import '../widgets/dialogs/error_dialog.dart';
import '../widgets/dialogs/loading_dialog.dart';

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

  UserBloc _userBloc;

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
        if (state is FailedSignInWithThirdParty) {
          if (state.message != null)
            DialogController.show(context, ErrorDialog(state.message));
        }
        if (state is CancelledSignInWithThirdParty) {
          Navigator.of(context).pop();
          DialogController.show(context, ErrorDialog(t('cancel')));
        }
        if (state is SignedInWithThirdParty) {
          Navigator.of(context).pop();
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
              Spacer(),
              PrimaryButton(
                  Platform.isIOS
                      ? t('sign_in_with_apple_id')
                      : t('sign_in_with_google_id'), () {
                this._bloc.add(
                    Platform.isIOS ? SignInWithApple() : SignInWithGoogle());
              },
                  icon: Platform.isIOS
                      ? appleIcon
                      : Row(
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.5, vertical: 8.0)),
            ],
          ),
        ),
      ),
    );
  }
}

double height = 44;
double fontSize = height * 0.43;

/// The scale based on the height of the button
const _appleIconSizeScale = 28 / 44;

final appleIcon = Container(
  width: _appleIconSizeScale * height,
  height: _appleIconSizeScale * height + 2,
  padding: EdgeInsets.only(
    // Properly aligns the Apple icon with the text of the button
    bottom: (4 / 44) * height,
  ),
  child: Center(
    child: Container(
      width: fontSize * (25 / 31),
      height: fontSize,
      child: CustomPaint(
        painter: lib.AppleLogoPainter(
          color: Colors.white,
        ),
      ),
    ),
  ),
);
