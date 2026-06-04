import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:canopy/features/auth/domain/entities/app_user.dart';
import 'package:canopy/features/auth/domain/entities/check_in_frequency.dart';
import 'package:canopy/features/auth/domain/entities/notification_preferences.dart';
import 'package:canopy/features/auth/domain/entities/plant_experience.dart';
import 'package:canopy/features/auth/domain/repositories/auth_repository.dart';
import 'package:canopy/features/auth/presentation/providers/auth_repository_provider.dart';
import 'package:canopy/features/you/presentation/providers/you_profile_provider.dart';
import 'package:canopy/features/you/presentation/services/avatar_picker.dart';

// ---------------------------------------------------------------------------
// Fake repository — captures updateUserProfile args, simulates failure
// ---------------------------------------------------------------------------

class _FakeAvatarPicker extends AvatarPicker {
  String? result;
  bool shouldThrow = false;
  int callCount = 0;

  @override
  Future<String?> pickAndEncode() async {
    callCount++;
    if (shouldThrow) throw Exception('decode failed');
    return result;
  }
}

class _FakeAuthRepository implements AuthRepository {
  bool shouldThrow = false;
  int updateCallCount = 0;
  String? lastUid;
  String? lastName;
  String? lastAvatarBase64;
  String? lastNeighborhood;
  CheckInFrequency? lastFrequency;
  PlantExperience? lastExperience;
  NotificationPreferences? lastNotificationPreferences;
  bool? lastOnboardingComplete;

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
    updateCallCount++;
    lastUid = uid;
    lastName = name;
    lastAvatarBase64 = avatarBase64;
    lastNeighborhood = neighborhood;
    lastFrequency = checkInFrequency;
    lastExperience = plantExperience;
    lastNotificationPreferences = notificationPreferences;
    lastOnboardingComplete = onboardingComplete;
    if (shouldThrow) throw Exception('Firestore write failed');
  }

  @override
  Future<AppUser> linkAnonymousAccount({
    required String uid,
    required Object credential,
  }) => throw UnimplementedError();
}

void main() {
  late _FakeAuthRepository fakeRepo;
  late _FakeAvatarPicker fakePicker;
  late ProviderContainer container;

  setUp(() {
    fakeRepo = _FakeAuthRepository();
    fakePicker = _FakeAvatarPicker();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeRepo),
        avatarPickerProvider.overrideWithValue(fakePicker),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('YouProfileController', () {
    test('initial state is not saving with no error', () {
      final state = container.read(youProfileControllerProvider);
      expect(state.isSaving, isFalse);
      expect(state.error, isNull);
    });

    test('updateName passes uid and name only', () async {
      final notifier = container.read(youProfileControllerProvider.notifier);

      await notifier.updateName('uid-1', 'New Name');

      expect(fakeRepo.updateCallCount, 1);
      expect(fakeRepo.lastUid, 'uid-1');
      expect(fakeRepo.lastName, 'New Name');
      expect(fakeRepo.lastNeighborhood, isNull);
      expect(fakeRepo.lastFrequency, isNull);
      expect(fakeRepo.lastExperience, isNull);
      expect(fakeRepo.lastNotificationPreferences, isNull);
      expect(fakeRepo.lastOnboardingComplete, isNull);
    });

    test('updateNeighborhood passes uid and neighborhood only', () async {
      final notifier = container.read(youProfileControllerProvider.notifier);

      await notifier.updateNeighborhood('uid-1', 'Ari');

      expect(fakeRepo.lastUid, 'uid-1');
      expect(fakeRepo.lastNeighborhood, 'Ari');
      expect(fakeRepo.lastName, isNull);
    });

    test('updateFrequency passes uid and frequency only', () async {
      final notifier = container.read(youProfileControllerProvider.notifier);

      await notifier.updateFrequency('uid-1', CheckInFrequency.onceAWeek);

      expect(fakeRepo.lastUid, 'uid-1');
      expect(fakeRepo.lastFrequency, CheckInFrequency.onceAWeek);
      expect(fakeRepo.lastName, isNull);
    });

    test('updateExperience passes uid and experience only', () async {
      final notifier = container.read(youProfileControllerProvider.notifier);

      await notifier.updateExperience('uid-1', PlantExperience.professional);

      expect(fakeRepo.lastUid, 'uid-1');
      expect(fakeRepo.lastExperience, PlantExperience.professional);
      expect(fakeRepo.lastName, isNull);
    });

    test('updateNotifications passes uid and preferences only', () async {
      final notifier = container.read(youProfileControllerProvider.notifier);
      const prefs = NotificationPreferences(
        wateringReminders: true,
        cityAlerts: false,
      );

      await notifier.updateNotifications('uid-1', prefs);

      expect(fakeRepo.lastUid, 'uid-1');
      expect(fakeRepo.lastNotificationPreferences, isNotNull);
      expect(fakeRepo.lastNotificationPreferences!.wateringReminders, isTrue);
      expect(fakeRepo.lastNotificationPreferences!.cityAlerts, isFalse);
      expect(fakeRepo.lastName, isNull);
    });

    test('never sets onboardingComplete', () async {
      final notifier = container.read(youProfileControllerProvider.notifier);

      await notifier.updateName('uid-1', 'New Name');
      await notifier.updateNeighborhood('uid-1', 'Silom');

      expect(fakeRepo.lastOnboardingComplete, isNull);
    });

    test('on success clears isSaving with no error', () async {
      final notifier = container.read(youProfileControllerProvider.notifier);

      await notifier.updateName('uid-1', 'New Name');

      final state = container.read(youProfileControllerProvider);
      expect(state.isSaving, isFalse);
      expect(state.error, isNull);
    });

    test('on failure sets error and clears isSaving', () async {
      fakeRepo.shouldThrow = true;
      final notifier = container.read(youProfileControllerProvider.notifier);

      await notifier.updateName('uid-1', 'New Name');

      final state = container.read(youProfileControllerProvider);
      expect(state.isSaving, isFalse);
      expect(state.error, isNotNull);
      expect(state.error, isNotEmpty);
    });

    test('updateAvatar saves the encoded image from the picker', () async {
      fakePicker.result = 'ZmFrZS1qcGVn';
      final notifier = container.read(youProfileControllerProvider.notifier);

      await notifier.updateAvatar('uid-1');

      expect(fakePicker.callCount, 1);
      expect(fakeRepo.updateCallCount, 1);
      expect(fakeRepo.lastUid, 'uid-1');
      expect(fakeRepo.lastAvatarBase64, 'ZmFrZS1qcGVn');
      expect(fakeRepo.lastName, isNull);
    });

    test('updateAvatar does nothing when the picker is cancelled', () async {
      fakePicker.result = null;
      final notifier = container.read(youProfileControllerProvider.notifier);

      await notifier.updateAvatar('uid-1');

      expect(fakeRepo.updateCallCount, 0);
      expect(container.read(youProfileControllerProvider).error, isNull);
    });

    test('updateAvatar sets error when the picker throws', () async {
      fakePicker.shouldThrow = true;
      final notifier = container.read(youProfileControllerProvider.notifier);

      await notifier.updateAvatar('uid-1');

      expect(fakeRepo.updateCallCount, 0);
      expect(container.read(youProfileControllerProvider).error, isNotNull);
    });

    test('a save after a failure clears the previous error', () async {
      fakeRepo.shouldThrow = true;
      final notifier = container.read(youProfileControllerProvider.notifier);
      await notifier.updateName('uid-1', 'New Name');
      expect(container.read(youProfileControllerProvider).error, isNotNull);

      fakeRepo.shouldThrow = false;
      await notifier.updateName('uid-1', 'Another Name');

      final state = container.read(youProfileControllerProvider);
      expect(state.error, isNull);
      expect(state.isSaving, isFalse);
    });
  });
}
