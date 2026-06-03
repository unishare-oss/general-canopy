import 'package:canopy/features/auth/domain/entities/check_in_frequency.dart';
import 'package:canopy/features/auth/domain/entities/notification_preferences.dart';
import 'package:canopy/features/auth/domain/entities/plant_experience.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.neighborhood,
    this.checkInFrequency,
    this.plantExperience,
    NotificationPreferences? notificationPreferences,
    this.onboardingComplete = false,
    this.providerIds = const <String>[],
    this.isAnonymous = false,
  }) : notificationPreferences =
           notificationPreferences ?? const NotificationPreferences();

  final String id;
  final String name;
  final String email;
  final String? photoUrl;

  /// Canopy-specific profile fields.
  final String? neighborhood;
  final CheckInFrequency? checkInFrequency;
  final PlantExperience? plantExperience;
  final NotificationPreferences notificationPreferences;
  final bool onboardingComplete;

  /// Firebase Auth provider IDs linked to this account.
  /// e.g. `google.com`, `password`, `apple.com`. Empty when unknown.
  final List<String> providerIds;

  final bool isAnonymous;
}
