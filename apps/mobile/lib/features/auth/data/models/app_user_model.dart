import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:canopy/features/auth/domain/entities/app_user.dart';
import 'package:canopy/features/auth/domain/entities/check_in_frequency.dart';
import 'package:canopy/features/auth/domain/entities/notification_preferences.dart';
import 'package:canopy/features/auth/domain/entities/plant_experience.dart';

part 'app_user_model.freezed.dart';
part 'app_user_model.g.dart';

@freezed
abstract class AppUserModel with _$AppUserModel {
  const AppUserModel._();

  const factory AppUserModel({
    required String id,
    required String name,
    required String email,
    String? photoUrl,
    String? neighborhood,
    String? checkInFrequency, // serialised enum name
    String? plantExperience, // serialised enum name
    @Default(false) bool wateringReminders,
    @Default(false) bool cityAlerts,
    @Default(false) bool onboardingComplete,
  }) = _AppUserModel;

  factory AppUserModel.fromJson(Map<String, dynamic> json) =>
      _$AppUserModelFromJson(json);

  factory AppUserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final prefs =
        data['notificationPreferences'] as Map<String, dynamic>? ?? {};
    return AppUserModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      neighborhood: data['neighborhood'] as String?,
      checkInFrequency: data['checkInFrequency'] as String?,
      plantExperience: data['plantExperience'] as String?,
      wateringReminders: prefs['wateringReminders'] as bool? ?? false,
      cityAlerts: prefs['cityAlerts'] as bool? ?? false,
      onboardingComplete: data['onboardingComplete'] as bool? ?? false,
    );
  }

  AppUser toEntity({List<String> providerIds = const <String>[]}) => AppUser(
    id: id,
    name: name,
    email: email,
    photoUrl: photoUrl,
    neighborhood: neighborhood,
    checkInFrequency: checkInFrequency != null
        ? CheckInFrequency.values.firstWhere((e) => e.name == checkInFrequency)
        : null,
    plantExperience: plantExperience != null
        ? PlantExperience.values.firstWhere((e) => e.name == plantExperience)
        : null,
    notificationPreferences: NotificationPreferences(
      wateringReminders: wateringReminders,
      cityAlerts: cityAlerts,
    ),
    onboardingComplete: onboardingComplete,
    providerIds: providerIds,
  );
}
