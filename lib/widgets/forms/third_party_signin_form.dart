import 'dart:io';

import 'package:flutter/material.dart';

import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../buttons/primary_button.dart';
import '../../helpers/i18n.dart';

import '../../helpers/logger.dart';

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
        painter: AppleLogoPainter(
          color: Colors.white,
        ),
      ),
    ),
  ),
);

class ThirdPartySignInForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 50.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(
            t('sign_in_with_apple_id'),
            () async {
              final credential = await SignInWithApple.getAppleIDCredential(
                scopes: [
                  AppleIDAuthorizationScopes.email,
                  AppleIDAuthorizationScopes.fullName,
                ],
                webAuthenticationOptions: WebAuthenticationOptions(
                  // ++: Set the `clientId` and `redirectUri` arguments to the values you entered in the Apple Developer portal during the setup
                  // ++ 目前設定是錯的 Emily 03/31/2021
                  clientId:
                      'com.example.tidewallet3.dart_packages.sign_in_with_apple.example',
                  redirectUri: Uri.parse(
                    'https://tidewallet3.glitch.me/callbacks/sign_in_with_apple',
                  ),
                ),
              );

              Log.debug(
                  'credential userIdentifier: ${credential.userIdentifier}');
            },
            icon: appleIcon,
          ),
        ],
      ),
    );
  }
}
