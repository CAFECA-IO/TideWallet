import 'package:flutter/material.dart';

import 'package:sign_in_with_apple/sign_in_with_apple.dart' as lib;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../buttons/primary_button.dart';
import '../../repositories/third_party_sign_in_repository.dart';
import '../../blocs/third_party_sign_in/third_party_sign_in_bloc.dart';
import '../../blocs/user/user_bloc.dart';

import '../../helpers/i18n.dart';

final t = I18n.t;
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

class ThirdPartySignInForm extends StatefulWidget {
  @override
  _ThirdPartySignInFormState createState() => _ThirdPartySignInFormState();
}

class _ThirdPartySignInFormState extends State<ThirdPartySignInForm> {
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
        if (state is FailedSignInWithApple) {}
        if (state is SignedInWithApple) {
          Navigator.of(context).pop();
          _userBloc.add(UserCreate(state.userIndentifier, 'tide'));
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 50.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryButton(
              t('sign_in_with_apple_id'),
              () {
                this._bloc.add(SignInWithApple());
              },
              icon: appleIcon,
            ),
          ],
        ),
      ),
    );
  }
}
