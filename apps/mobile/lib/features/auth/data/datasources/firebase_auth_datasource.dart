import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:canopy/features/auth/domain/entities/auth_exception.dart';

class FirebaseAuthDatasource {
  FirebaseAuthDatasource({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> signInAnonymously() async {
    try {
      return await _firebaseAuth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    }
  }

  /// Returns null if the user cancels. Caller treats null as a silent no-op.
  Future<UserCredential?> signInWithGoogle() async {
    late final GoogleSignInAccount googleUser;
    try {
      googleUser = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        return null;
      }
      throw AuthException(AuthFailureType.unknown, e.description);
    }

    final idToken = googleUser.authentication.idToken;
    final credential = GoogleAuthProvider.credential(idToken: idToken);

    try {
      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    }
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      GoogleSignIn.instance.signOut(),
    ]);
  }

  Future<UserCredential> linkWithCredential(AuthCredential credential) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw const AuthException(AuthFailureType.unknown);
      return await user.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    }
  }

  AuthException _mapException(FirebaseAuthException e) {
    debugPrint('FirebaseAuthException [${e.code}]: ${e.message}');
    return switch (e.code) {
      'wrong-password' || 'user-not-found' || 'invalid-credential' =>
        const AuthException(AuthFailureType.invalidCredentials),
      'email-already-in-use' || 'credential-already-in-use' =>
        const AuthException(AuthFailureType.emailAlreadyInUse),
      'network-request-failed' =>
        const AuthException(AuthFailureType.networkError),
      'operation-not-allowed' =>
        const AuthException(AuthFailureType.providerDisabled),
      _ => const AuthException(AuthFailureType.unknown),
    };
  }
}
