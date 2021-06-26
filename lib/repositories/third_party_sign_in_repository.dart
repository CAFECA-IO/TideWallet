import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../helpers/logger.dart';
import '../helpers/mnemonic/core.dart';

class ThirdPartySignInRepository {
  Future<List> signInWithAppleId() async {
    AuthorizationCredentialAppleID credential;
    bool result = false;
    AuthorizationErrorCode errorCode;
    String errorMessage;
    try {
      credential = await SignInWithApple.getAppleIDCredential(scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ]);
      if (credential != null) result = true;
      Log.debug('credential userIdentifier: ${credential.userIdentifier}');
    } catch (e) {
      errorCode = e.code;
      errorMessage = e.message;
      Log.debug(e.code);
    }
    return [
      result,
      result ? credential?.userIdentifier : errorCode,
      !result ? errorMessage : null
    ];
  }

  Future<List> signInWithGoogleId() async {
    bool result = false;
    String userIdentifier;
    String errorMessage;
    dynamic errorCode;

    final GoogleSignIn _googleSignIn = GoogleSignIn();
    GoogleSignInAccount googleSignInAccount;

    try {
      googleSignInAccount = await _googleSignIn.signIn();
      Log.debug('googleSignInAccount.id: ${googleSignInAccount?.id}');
      userIdentifier = googleSignInAccount?.id;
      result = true;
    } on PlatformException catch (exception) {
      Log.debug(exception);
      errorCode = exception.code;
      errorMessage = exception.message;
    } catch (e) {
      Log.debug(e.toString());
    }

    return [
      result,
      result ? userIdentifier : errorCode,
      !result ? errorMessage : null
    ];
  }

  Future<bool> checkMnemonicVaildity(String mnemonic) async {
    return compute(Mnemonic.checkMnemonicVaildity, mnemonic);
  }

  Future<Uint8List> mnemonicToSeed(String mnemonic, String passphrase) async {
    return compute(Mnemonic.mnemonicToSeed, [mnemonic, passphrase]);
  }
}
