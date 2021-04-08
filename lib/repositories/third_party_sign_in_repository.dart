import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../helpers/logger.dart';

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
    FirebaseUser _user;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    try {
      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      Log.debug('googleSignInAccount.id: ${googleSignInAccount.id}');
      try {
        GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        if (googleSignInAuthentication != null) {
          Log.debug(
              'googleSignInAuthentication.accessToken: ${googleSignInAuthentication.accessToken}');
          Log.debug(
              'googleSignInAuthentication.idToken: ${googleSignInAuthentication.idToken}');
          AuthCredential credential = GoogleAuthProvider.getCredential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken,
          );
          try {
            AuthResult authResult =
                await _auth.signInWithCredential(credential);
            _user = authResult.user;
            assert(!_user.isAnonymous);
            assert(await _user.getIdToken() != null);
            FirebaseUser currentUser = await _auth.currentUser();
            assert(_user.uid == currentUser.uid);
            result = true;
            userIdentifier = _user.uid;
            Log.debug("User uid ${_user.uid}");
          } catch (e) {
            Log.debug(e.code);
            errorCode = e.code;
            errorMessage = e.message;
          }
        }
      } catch (e) {
        Log.debug(e.code);
        errorCode = e.code;
        errorMessage = e.message;
      }
    } catch (e) {
      Log.debug(e.code);
      errorCode = e.code;
      errorMessage = e.message;
    }
    return [
      result,
      result ? userIdentifier : errorCode,
      !result ? errorMessage : null
    ];
  }
}
