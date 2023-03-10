import 'dart:convert';

import 'package:comein/components/platform_graphics.dart';
import 'package:comein/models/data_model.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;
  AuthenticationService(this._firebaseAuth);
  User? getUser() => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.userChanges();

  // add fcm token to cloud firestore user document
  Future<void> addToken() async {
    final docRef = firebaseFirestore
        .collection('users')
        .doc(_firebaseAuth.currentUser?.uid);
    await firebaseFirestore.runTransaction((t) async {
      var snapshot = await t.get(docRef);
      List newTokens = snapshot.data()?['FCMtokens'];
      print("have tokens: ${newTokens}");
      if (!newTokens.contains(dataModel.token) && dataModel.token != null) {
        print("adding token: ${dataModel.token}");
        newTokens.add(dataModel.token!);
      }
      return t.update(docRef, {'FCMtokens': newTokens});
    });
  }

  // remove fcm token from cloud firestore user document
  Future<void> removeToken() async {
    final docRef = firebaseFirestore
        .collection('users')
        .doc(_firebaseAuth.currentUser?.uid);
    if ((await docRef.get()).data() == null) return;
    await firebaseFirestore.runTransaction((t) async {
      var snapshot = await t.get(docRef);
      List newTokens = snapshot.data()?['FCMtokens'];
      if (dataModel.token != null)
        newTokens.removeWhere((e) => e == dataModel.token);
      return t.update(docRef, {'FCMtokens': newTokens});
    });
  }

  // sign in with email and password
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      addToken();
      return "Signed in";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // deal with forgotten passwords
  Future<String?> forgotPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return "sent";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // sign up with email, password, and a display name
  Future<String?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (_firebaseAuth.currentUser?.isAnonymous ?? false) {
      AuthCredential credential =
          EmailAuthProvider.credential(email: email, password: password);
      try {
        await _firebaseAuth.currentUser?.linkWithCredential(credential);
        _firebaseAuth.currentUser?.updateDisplayName(displayName);
        _firebaseAuth.currentUser?.sendEmailVerification();
        return "Signed Up";
      } on FirebaseAuthException catch (e) {
        return e.message;
      }
    } else {
      try {
        await _firebaseAuth.createUserWithEmailAndPassword(
            email: email, password: password);
        _firebaseAuth.currentUser?.updateDisplayName(displayName);
        _firebaseAuth.currentUser?.sendEmailVerification();
        return "Signed up";
      } on FirebaseAuthException catch (e) {
        return e.message;
      }
    }
  }

  Future<void> signOut() async {
    await removeToken();
    return _firebaseAuth.signOut();
  }

  Future<UserCredential?> signInWithGoogle() async {
    if (NewPlatform.isWeb) {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider
          .addScope('https://www.googleapis.com/auth/contacts.readonly');
      googleProvider.setCustomParameters({'login_hint': 'user@example.com'});
      return await _firebaseAuth.signInWithPopup(googleProvider);
    }
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      if (_firebaseAuth.currentUser?.isAnonymous ?? false) {
        return _firebaseAuth.currentUser?.linkWithCredential(credential);
      }
      print("REACHED");
      var result = await _firebaseAuth.signInWithCredential(credential);
      // addToken();
      return result;
    }
    return null;
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential> signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  Future<UserCredential?> signInWithAnonymous() async {
    if (_firebaseAuth.currentUser?.isAnonymous ?? false) return null;
    return _firebaseAuth.signInAnonymously();
  }
}
