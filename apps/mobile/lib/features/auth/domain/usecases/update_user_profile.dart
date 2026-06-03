import 'package:canopy/features/auth/domain/entities/check_in_frequency.dart';
import 'package:canopy/features/auth/domain/entities/notification_preferences.dart';
import 'package:canopy/features/auth/domain/entities/plant_experience.dart';
import 'package:canopy/features/auth/domain/repositories/auth_repository.dart';

class UpdateUserProfile {
  const UpdateUserProfile(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String uid,
    String? name,
    String? neighborhood,
    CheckInFrequency? checkInFrequency,
    PlantExperience? plantExperience,
    NotificationPreferences? notificationPreferences,
    bool? onboardingComplete,
  }) => _repository.updateUserProfile(
    uid: uid,
    name: name,
    neighborhood: neighborhood,
    checkInFrequency: checkInFrequency,
    plantExperience: plantExperience,
    notificationPreferences: notificationPreferences,
    onboardingComplete: onboardingComplete,
  );
}
