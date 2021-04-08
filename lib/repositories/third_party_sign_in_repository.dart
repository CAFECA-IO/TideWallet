import 'dart:convert' show json;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../helpers/logger.dart';

import "package:http/http.dart" as http;

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
    FirebaseUser _user;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
    Log.debug(await googleSignInAccount.authHeaders);
    Log.debug(googleSignInAccount.displayName);
    GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    Log.debug(googleSignInAuthentication.accessToken);
    Log.debug(googleSignInAuthentication.idToken);

    AuthResult authResult = await _auth.signInWithCredential(credential);

    _user = authResult.user;

    assert(!_user.isAnonymous);

    assert(await _user.getIdToken() != null);

    FirebaseUser currentUser = await _auth.currentUser();

    assert(_user.uid == currentUser.uid);

    Log.debug("User Name: ${_user.displayName}");
    Log.debug("User Email ${_user.email}");
  }
}
