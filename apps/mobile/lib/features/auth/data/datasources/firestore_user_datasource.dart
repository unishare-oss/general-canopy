import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:canopy/features/auth/data/models/app_user_model.dart';
import 'package:canopy/features/auth/domain/entities/check_in_frequency.dart';
import 'package:canopy/features/auth/domain/entities/notification_preferences.dart';
import 'package:canopy/features/auth/domain/entities/plant_experience.dart';

class FirestoreUserDatasource {
  FirestoreUserDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<AppUserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return AppUserModel.fromFirestore(doc);
  }

  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    await _users.doc(uid).set({
      'name': name,
      'email': email,
      // ignore: use_null_aware_elements
      if (photoUrl != null) 'photoUrl': photoUrl,
      'onboardingComplete': false,
      'notificationPreferences': {
        'wateringReminders': false,
        'cityAlerts': false,
      },
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? neighborhood,
    CheckInFrequency? checkInFrequency,
    PlantExperience? plantExperience,
    NotificationPreferences? notificationPreferences,
    bool? onboardingComplete,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (neighborhood != null) data['neighborhood'] = neighborhood;
    if (checkInFrequency != null) {
      data['checkInFrequency'] = checkInFrequency.name;
    }
    if (plantExperience != null) {
      data['plantExperience'] = plantExperience.name;
    }
    if (notificationPreferences != null) {
      data['notificationPreferences'] = {
        'wateringReminders': notificationPreferences.wateringReminders,
        'cityAlerts': notificationPreferences.cityAlerts,
      };
    }
    if (onboardingComplete != null) {
      data['onboardingComplete'] = onboardingComplete;
    }
    if (data.isEmpty) return;
    await _users.doc(uid).update(data);
  }
}
