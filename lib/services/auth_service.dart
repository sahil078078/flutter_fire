import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'google_auth_service.dart';

class AuthService {
  AuthService._();

  static final _auth = FirebaseAuth.instance;

  static Stream<User?> get authState => _auth.authStateChanges();

  static User? get currentUser => _auth.currentUser;

  //! Google Sign in
  static Future<UserCredential?> googleSignIn() async {
    try {
      final googleAuth = await GoogleAuthService.googleSignInToken();
      if (googleAuth == null) {
        Fluttertoast.showToast(msg: "Google Sign-In cancelled");
        return null;
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential); 
      debugPrint('User Credential : ${userCredential.user}');
      Fluttertoast.showToast(msg: "Logged in as ${userCredential.user?.displayName ?? 'User'}");
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Google Auth Exception: $e');
      Fluttertoast.showToast(msg: e.message ?? "Google authentication failed");
      return null;
    } catch (e) {
      debugPrint('Google Auth Error: $e');
      Fluttertoast.showToast(msg: "An unexpected error occurred");
      return null;
    }
  }

  //! Email & Password Sign Up
  static Future<UserCredential?> signUpWithEmailAndPassword(String email, String password, String name) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();

      Fluttertoast.showToast(msg: "Registration successful!");
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('SignUp Exception: $e');
      Fluttertoast.showToast(msg: e.message ?? "Registration failed");
      return null;
    } catch (e) {
      debugPrint('SignUp Error: $e');
      Fluttertoast.showToast(msg: "An unexpected error occurred");
      return null;
    }
  }

  //! Email & Password Sign In
  static Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Fluttertoast.showToast(msg: "Welcome back!");
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('SignIn Exception: $e');
      Fluttertoast.showToast(msg: e.message ?? "Sign-in failed");
      return null;
    } catch (e) {
      debugPrint('SignIn Error: $e');
      Fluttertoast.showToast(msg: "An unexpected error occurred");
      return null;
    }
  }

  //! Sign Out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      await GoogleAuthService.googleSignOut();
      Fluttertoast.showToast(msg: "Signed out successfully");
    } catch (e) {
      debugPrint('SignOut Error: $e');
      Fluttertoast.showToast(msg: "Failed to sign out");
    }
  }
}
