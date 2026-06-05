import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';

import 'package:canopy/features/auth/data/models/app_user_model.dart';
import 'package:canopy/features/auth/domain/entities/app_user.dart';
import 'package:canopy/features/auth/domain/entities/check_in_frequency.dart';
import 'package:canopy/features/auth/domain/entities/notification_preferences.dart';
import 'package:canopy/features/auth/domain/entities/plant_experience.dart';
import 'package:canopy/features/auth/domain/repositories/auth_repository.dart';
import 'package:canopy/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:canopy/features/auth/data/datasources/firestore_user_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required FirebaseAuthDatasource authDatasource,
    required FirestoreUserDatasource firestoreDatasource,
  }) : _auth = authDatasource,
       _firestore = firestoreDatasource;

  final FirebaseAuthDatasource _auth;
  final FirestoreUserDatasource _firestore;

  @override
  Stream<AppUser?> get authStateChanges {
    return _auth.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      if (firebaseUser.isAnonymous) {
        return AppUser(
          id: firebaseUser.uid,
          name: '',
          email: '',
          isAnonymous: true,
        );
      }
      final providerIds = _providerIds(firebaseUser);
      AppUserModel? model;
      try {
        model = await _firestore.getUser(firebaseUser.uid);
      } catch (e) {
        // Firestore read failed (e.g. rules not deployed, network error).
        // Fall back to Firebase Auth data so the stream stays healthy.
        debugPrint('authStateChanges: Firestore read failed: $e');
      }
      // Fall back to Firebase Auth data if the Firestore document doesn't
      // exist yet (new-user race condition), was never created, or could not
      // be read. onboardingComplete defaults to false, triggering the quiz.
      return model?.toEntity(providerIds: providerIds) ??
          AppUser(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? '',
            email: firebaseUser.email ?? '',
            photoUrl: firebaseUser.photoURL,
            providerIds: providerIds,
            onboardingComplete: false,
          );
    });
  }

  List<String> _providerIds(firebase_auth.User user) =>
      user.providerData.map((p) => p.providerId).toList(growable: false);

  @override
  Future<AppUser> signInAnonymously() async {
    final credential = await _auth.signInAnonymously();
    final firebaseUser = credential.user!;
    return AppUser(
      id: firebaseUser.uid,
      name: '',
      email: '',
      isAnonymous: true,
    );
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    final credential = await _auth.signInWithGoogle();
    // User cancelled — silently return guest-like behaviour by throwing,
    // but the caller (provider) handles null credential as a no-op.
    if (credential == null) {
      throw StateError('Google sign-in cancelled');
    }

    final firebaseUser = credential.user!;
    final isNew = credential.additionalUserInfo?.isNewUser ?? false;
    final providerIds = _providerIds(firebaseUser);

    if (isNew) {
      await _firestore.createUser(
        uid: firebaseUser.uid,
        name: firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? '',
        photoUrl: firebaseUser.photoURL,
      );
      return AppUser(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? '',
        photoUrl: firebaseUser.photoURL,
        providerIds: providerIds,
        onboardingComplete: false,
      );
    }

    final model = await _firestore.getUser(firebaseUser.uid);
    return model!.toEntity(providerIds: providerIds);
  }

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final firebaseUser = credential.user!;
    final model = await _firestore.getUser(firebaseUser.uid);
    return model!.toEntity(providerIds: _providerIds(firebaseUser));
  }

  @override
  Future<AppUser> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;

    // Set displayName on the Firebase Auth profile so it's available
    // when other features read user.displayName.
    await credential.user!.updateDisplayName(name);

    await _firestore.createUser(uid: uid, name: name, email: email);

    return AppUser(
      id: uid,
      name: name,
      email: email,
      providerIds: _providerIds(credential.user!),
      onboardingComplete: false,
    );
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    if (firebaseUser.isAnonymous) {
      return AppUser(
        id: firebaseUser.uid,
        name: '',
        email: '',
        isAnonymous: true,
      );
    }
    final providerIds = _providerIds(firebaseUser);
    final model = await _firestore.getUser(firebaseUser.uid);
    return model?.toEntity(providerIds: providerIds);
  }

  @override
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? avatarBase64,
    String? neighborhood,
    CheckInFrequency? checkInFrequency,
    PlantExperience? plantExperience,
    NotificationPreferences? notificationPreferences,
    bool? onboardingComplete,
  }) => _firestore.updateUserProfile(
    uid: uid,
    name: name,
    avatarBase64: avatarBase64,
    neighborhood: neighborhood,
    checkInFrequency: checkInFrequency,
    plantExperience: plantExperience,
    notificationPreferences: notificationPreferences,
    onboardingComplete: onboardingComplete,
  );

  @override
  Future<AppUser> linkAnonymousAccount({
    required String uid,
    required Object credential,
  }) async {
    final authCredential = credential as firebase_auth.AuthCredential;
    final userCredential = await _auth.linkWithCredential(authCredential);
    final firebaseUser = userCredential.user!;
    final providerIds = _providerIds(firebaseUser);
    final model = await _firestore.getUser(firebaseUser.uid);
    return model?.toEntity(providerIds: providerIds) ??
        AppUser(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
          photoUrl: firebaseUser.photoURL,
          providerIds: providerIds,
        );
  }
}
