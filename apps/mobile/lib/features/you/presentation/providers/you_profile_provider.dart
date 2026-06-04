import 'package:canopy/features/auth/domain/entities/check_in_frequency.dart';
import 'package:canopy/features/auth/domain/entities/notification_preferences.dart';
import 'package:canopy/features/auth/domain/entities/plant_experience.dart';
import 'package:canopy/features/auth/domain/usecases/update_user_profile.dart';
import 'package:canopy/features/auth/presentation/providers/auth_repository_provider.dart';
import 'package:canopy/features/auth/presentation/providers/current_user_provider.dart';
import 'package:canopy/features/you/presentation/services/avatar_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'you_profile_provider.g.dart';

class YouProfileEditState {
  const YouProfileEditState({this.isSaving = false, this.error});

  final bool isSaving;
  final String? error;

  YouProfileEditState copyWith({
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) => YouProfileEditState(
    isSaving: isSaving ?? this.isSaving,
    error: clearError ? null : error ?? this.error,
  );
}

@riverpod
class YouProfileController extends _$YouProfileController {
  @override
  YouProfileEditState build() => const YouProfileEditState();

  Future<void> updateName(String uid, String name) => _save(uid, name: name);

  Future<void> updateNeighborhood(String uid, String neighborhood) =>
      _save(uid, neighborhood: neighborhood);

  Future<void> updateFrequency(String uid, CheckInFrequency frequency) =>
      _save(uid, checkInFrequency: frequency);

  Future<void> updateExperience(String uid, PlantExperience experience) =>
      _save(uid, plantExperience: experience);

  Future<void> updateNotifications(
    String uid,
    NotificationPreferences preferences,
  ) => _save(uid, notificationPreferences: preferences);

  /// Opens the image picker, compresses the chosen photo, and saves it as
  /// the user's avatar. No-op when the user cancels the picker.
  Future<void> updateAvatar(String uid) async {
    final String? encoded;
    try {
      encoded = await ref.read(avatarPickerProvider).pickAndEncode();
    } catch (_) {
      state = state.copyWith(
        error: 'Could not read that image. Please try another one.',
      );
      return;
    }
    if (encoded == null) return;
    await _save(uid, avatarBase64: encoded);
  }

  /// Writes the single changed field to Firestore (null fields are left
  /// unchanged by [UpdateUserProfile]). On success invalidates
  /// [currentUserProvider] so the screen re-reads fresh data — the
  /// authStateChanges stream does not re-emit on Firestore writes.
  /// On failure sets [YouProfileEditState.error]; caller shows a SnackBar.
  Future<void> _save(
    String uid, {
    String? name,
    String? avatarBase64,
    String? neighborhood,
    CheckInFrequency? checkInFrequency,
    PlantExperience? plantExperience,
    NotificationPreferences? notificationPreferences,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final repository = ref.read(authRepositoryProvider);
      await UpdateUserProfile(repository).call(
        uid: uid,
        name: name,
        avatarBase64: avatarBase64,
        neighborhood: neighborhood,
        checkInFrequency: checkInFrequency,
        plantExperience: plantExperience,
        notificationPreferences: notificationPreferences,
      );
      ref.invalidate(currentUserProvider);
      state = state.copyWith(isSaving: false);
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        error: 'Something went wrong. Please try again.',
      );
    }
  }
}
