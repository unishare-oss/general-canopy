import 'package:canopy/features/auth/domain/entities/app_user.dart';
import 'package:canopy/features/auth/domain/entities/check_in_frequency.dart';
import 'package:canopy/features/auth/domain/entities/notification_preferences.dart';
import 'package:canopy/features/auth/domain/entities/plant_experience.dart';

abstract interface class AuthRepository {
  /// Emits null when signed out, AppUser when signed in (including anonymous).
  Stream<AppUser?> get authStateChanges;

  Future<AppUser> signInAnonymously();

  Future<AppUser> signInWithGoogle();

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AppUser> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<AppUser?> getCurrentUser();

  /// Updates mutable profile fields. All parameters are optional; pass only
  /// the fields that have changed.
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? avatarBase64,
    String? neighborhood,
    CheckInFrequency? checkInFrequency,
    PlantExperience? plantExperience,
    NotificationPreferences? notificationPreferences,
    bool? onboardingComplete,
  });

  /// Merges an anonymous session into a permanent account by linking the
  /// given credential. Returns the upgraded AppUser.
  /// Throws [AuthException] with type [AuthFailureType.emailAlreadyInUse]
  /// if the credential belongs to an existing account.
  ///
  /// Note: [credential] is declared as [Object] to keep the domain layer
  /// free of Firebase imports. The Data layer casts to
  /// `firebase_auth.AuthCredential` at runtime.
  Future<AppUser> linkAnonymousAccount({
    required String uid,
    required Object credential,
  });
}
