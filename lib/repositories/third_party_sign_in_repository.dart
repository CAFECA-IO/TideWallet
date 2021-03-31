import 'package:flutter/services.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../helpers/logger.dart';

class ThirdPartySignInRepository {
  Future<List> signInWithAppleId() async {
    AuthorizationCredentialAppleID credential;
    bool result = false;
    AuthorizationErrorCode errorCode;
    String errorMessage;
    try {
      credential = await SignInWithApple.getAppleIDCredential(
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
      if (credential != null) result = true;
    } catch (e) {
      errorCode = e.code;
      errorMessage = e.message;
      Log.debug(e.code);
    }

    Log.debug('credential userIdentifier: ${credential.userIdentifier}');
    return [
      result,
      result ? credential?.userIdentifier : errorCode,
      !result ? errorMessage : null
    ];
  }
}
