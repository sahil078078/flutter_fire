import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  GoogleAuthService._();

  //Google Sign In
  static bool _isInitGoogleSignInInstance = false;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static Future<GoogleSignInAuthentication?> googleSignInToken() async {
    if (!_isInitGoogleSignInInstance) {
      await _googleSignIn.initialize();
      _isInitGoogleSignInInstance = true;
    }

    try {
      final account = await _googleSignIn.authenticate(scopeHint: ['email', 'profile']);
      final GoogleSignInAuthentication auth = account.authentication;
      debugPrint('Google SignIn Token : ${auth.idToken}');
      return auth;
    } on GoogleSignInException catch (e) {
      debugPrint('Google SignIn Exception : $e');
      Fluttertoast.showToast(msg: '${e.description ?? e.code}');
      return null;
    } catch (e) {
      debugPrint('Google SignIn Error : $e');
      return null;
    }
  }

  static Future<void> googleSignOut() async {
    await _googleSignIn.signOut();
  }
}
