import 'package:flutter_test/flutter_test.dart';

import 'package:canopy/features/auth/domain/entities/app_user.dart';
import 'package:canopy/features/auth/domain/entities/check_in_frequency.dart';
import 'package:canopy/features/auth/domain/entities/notification_preferences.dart';
import 'package:canopy/features/auth/domain/entities/plant_experience.dart';
import 'package:canopy/features/auth/domain/repositories/auth_repository.dart';
import 'package:canopy/features/auth/domain/usecases/update_user_profile.dart';

// ---------------------------------------------------------------------------
// Spy repository — captures the arguments passed to updateUserProfile
// ---------------------------------------------------------------------------

class _SpyAuthRepository implements AuthRepository {
  String? capturedUid;
  String? capturedName;
  String? capturedNeighborhood;
  CheckInFrequency? capturedFrequency;
  PlantExperience? capturedExperience;
  NotificationPreferences? capturedPreferences;
  bool? capturedOnboardingComplete;

  @override
  Stream<AppUser?> get authStateChanges => const Stream.empty();

  @override
  Future<AppUser> signInAnonymously() => throw UnimplementedError();

  @override
  Future<AppUser> signInWithGoogle() => throw UnimplementedError();

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<AppUser> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<void> signOut() async {}

  @override
  Future<AppUser?> getCurrentUser() async => null;

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
  }) async {
    capturedUid = uid;
    capturedName = name;
    capturedNeighborhood = neighborhood;
    capturedFrequency = checkInFrequency;
    capturedExperience = plantExperience;
    capturedPreferences = notificationPreferences;
    capturedOnboardingComplete = onboardingComplete;
  }

  @override
  Future<AppUser> linkAnonymousAccount({
    required String uid,
    required Object credential,
  }) => throw UnimplementedError();
}

void main() {
  test(
    'UpdateUserProfile delegates all parameters to AuthRepository.updateUserProfile',
    () async {
      final repo = _SpyAuthRepository();
      final useCase = UpdateUserProfile(repo);

      const prefs = NotificationPreferences(
        wateringReminders: true,
        cityAlerts: false,
      );

      await useCase(
        uid: 'uid-test',
        name: 'Alice',
        neighborhood: 'East Park',
        checkInFrequency: CheckInFrequency.mostDays,
        plantExperience: PlantExperience.beginner,
        notificationPreferences: prefs,
        onboardingComplete: true,
      );

      expect(repo.capturedUid, 'uid-test');
      expect(repo.capturedName, 'Alice');
      expect(repo.capturedNeighborhood, 'East Park');
      expect(repo.capturedFrequency, CheckInFrequency.mostDays);
      expect(repo.capturedExperience, PlantExperience.beginner);
      expect(repo.capturedPreferences?.wateringReminders, isTrue);
      expect(repo.capturedOnboardingComplete, isTrue);
    },
  );
}
