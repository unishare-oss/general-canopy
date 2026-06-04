import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:canopy/features/auth/data/datasources/firestore_user_datasource.dart';
import 'package:canopy/features/auth/data/models/app_user_model.dart';
import 'package:canopy/features/auth/domain/entities/check_in_frequency.dart';
import 'package:canopy/features/auth/domain/entities/notification_preferences.dart';
import 'package:canopy/features/auth/domain/entities/plant_experience.dart';

// ---------------------------------------------------------------------------
// Minimal FirebaseFirestore stub — never touches the SDK
// ---------------------------------------------------------------------------

class _StubFirestore extends Fake implements FirebaseFirestore {}

// ---------------------------------------------------------------------------
// In-memory fake for [FirestoreUserDatasource].
// ---------------------------------------------------------------------------

class FakeFirestoreUserDatasource extends FirestoreUserDatasource {
  FakeFirestoreUserDatasource() : super(firestore: _StubFirestore());

  final Map<String, AppUserModel> storedUsers = {};
  int createUserCallCount = 0;
  int updateUserProfileCallCount = 0;

  // Captures from the last updateUserProfile call
  String? lastUpdateUid;
  String? lastUpdateName;
  String? lastUpdateNeighborhood;
  CheckInFrequency? lastUpdateFrequency;
  PlantExperience? lastUpdateExperience;
  NotificationPreferences? lastUpdateNotificationPreferences;
  bool? lastUpdateOnboardingComplete;

  /// When set, the next updateUserProfile call throws this error.
  Object? updateError;

  @override
  Future<AppUserModel?> getUser(String uid) async => storedUsers[uid];

  @override
  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    createUserCallCount++;
    storedUsers[uid] = AppUserModel(
      id: uid,
      name: name,
      email: email,
      photoUrl: photoUrl,
    );
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
  }) async {
    updateUserProfileCallCount++;
    lastUpdateUid = uid;
    lastUpdateName = name;
    lastUpdateNeighborhood = neighborhood;
    lastUpdateFrequency = checkInFrequency;
    lastUpdateExperience = plantExperience;
    lastUpdateNotificationPreferences = notificationPreferences;
    lastUpdateOnboardingComplete = onboardingComplete;

    if (updateError != null) {
      throw updateError!;
    }

    final existing = storedUsers[uid];
    if (existing != null) {
      storedUsers[uid] = existing.copyWith(
        name: name ?? existing.name,
        neighborhood: neighborhood ?? existing.neighborhood,
        checkInFrequency: checkInFrequency?.name ?? existing.checkInFrequency,
        plantExperience: plantExperience?.name ?? existing.plantExperience,
        wateringReminders:
            notificationPreferences?.wateringReminders ??
            existing.wateringReminders,
        cityAlerts: notificationPreferences?.cityAlerts ?? existing.cityAlerts,
        onboardingComplete: onboardingComplete ?? existing.onboardingComplete,
      );
    }
  }
}
