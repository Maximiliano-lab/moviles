import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static bool isInitialize = false;

  static Future<void> initSignIn() async {
    if (!isInitialize) {
      await _googleSignIn.initialize(
        serverClientId: "317737345454-mfqgm87rvrji90bga6b25j2c3u43bsmu.apps.googleusercontent.com",
      );
      isInitialize = true;
    }
  }

  static Future<UserCredential?> singInWithGoogle() async {
    try {
      await initSignIn(); // <- con await

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final String? idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'missing-id-token',
          message: 'No se pudo obtener el idToken de Google.',
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      final User? user = userCredential.user;
      if (user != null) {
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        final docSnapshot = await userDoc.get();
        if (!docSnapshot.exists) {
          await userDoc.set({
            'uid': user.uid,
            'name': user.displayName ?? '',
            'email': user.email ?? '',
            'photoUrl': user.photoURL ?? '',
            'provider': 'google',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      return userCredential;
    } on GoogleSignInException catch (e) {
      debugPrint('Google Sign-In cancelado o con error: ${e.code}');
      return null;
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  static User? getCurrentUser() => _auth.currentUser;
}
