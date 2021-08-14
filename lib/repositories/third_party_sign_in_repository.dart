import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../helpers/logger.dart';
// import '../helpers/exceptions.dart';
import '../helpers/mnemonic/core.dart';

class ThirdPartySignInRepository {
  String? _thirdPartyId;

  String get thirdPartyId {
    return this._thirdPartyId!;
  }

  Future<List> signInWithAppleId() async {
    try {
      AuthorizationCredentialAppleID credential =
          await SignInWithApple.getAppleIDCredential(scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ]);
      Log.debug('signInWithAppleId: ${credential.userIdentifier}');
      this._thirdPartyId = credential.userIdentifier!;
      return [true, credential.userIdentifier!];
    } catch (e) {
      dynamic exception = e;
      AuthorizationErrorCode errorCode = exception.code;
      late String message;
      switch (errorCode) {
        case AuthorizationErrorCode.canceled:
          message = 'cancel';
          break;
        case AuthorizationErrorCode.failed:
        case AuthorizationErrorCode.invalidResponse:
        case AuthorizationErrorCode.notHandled:
        case AuthorizationErrorCode.unknown:
          message = exception.message;
          break;
        default:
          message = 'Something went wrong...';
          break;
      }
      return [false, message];
    }
  }

  Future<List> signInWithGoogleId() async {
    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn();
      GoogleSignInAccount googleSignInAccount = (await _googleSignIn.signIn())!;
      Log.debug('googleSignInAccount.id: ${googleSignInAccount.id}');
      this._thirdPartyId = googleSignInAccount.id;
      return [true, googleSignInAccount.id];
    } on PlatformException catch (exception) {
      Log.debug(exception);
      return [false, exception.message];
    } catch (e) {
      Log.debug(e.toString());
      return [false, 'Something went wrong...'];
    }
  }

  Future<bool> checkMnemonicVaildity(String mnemonic) async {
    return compute(Mnemonic.checkMnemonicVaildity, mnemonic);
  }

  Future<Uint8List> mnemonicToSeed(String mnemonic, String passphrase) async {
    return compute(Mnemonic.mnemonicToSeed, [mnemonic, passphrase]);
  }
}
